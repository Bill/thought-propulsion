module Kernel
  def capture # pass a block to capture
     old_stdout = $stdout
     out = StringIO.new
     $stdout = out
     begin
        yield
     ensure
        $stdout = old_stdout
     end
     out.string
  end
  module_function :capture
end

class NamedRoutesWrapper
  # the helpers are made protected by default--we make them public for
  # easier access during testing and troubleshooting.
  #NOTE: not really needed to be valid.. its a nice-to-have for testing
  def helpers
    [] 
  end
end


class ActionController::Routing::MerbRoutingWrapper
  # this setter is used by rails dispatcher but isn't actually used by us
  attr_writer :configuration_file
  attr_accessor :configuration_files, :routes, :named_routes

  def initialize
    self.configuration_files = []

    self.routes = []
  end

  def add_configuration_file(path)
    self.configuration_files << path
  end

  def configuration_file
    "#{RAILS_ROOT}/config/router.rb"
  end

  # mixes in url(), polymorphic_path stuff, and method_missing to catch named_route_path stuff
  def install_helpers(klass)
    klass.module_eval do
      include ActionController::Routing::Helpers
      include Merb::Router::UrlHelpers
    end
  end
  
  def named_routes
     NamedRoutesWrapper.new
  end
  
  # rebuilds routes
  def reload
    return if (mtime = File.stat(configuration_file).mtime) && mtime == @routes_last_modified
    [ActionController::Base, ActionView::Base].each { |d| install_helpers(d) }
    Merb::Router.reset!
    @routes_last_modified = mtime
    @routes_by_controller = nil
    load configuration_file
  end

  def reload!
    reload
  end

  # called in Rails 2.3 and earlier by ActionController::Routing::Routes.recognize_path which in turn calls
  # params_from( method, path, options)
  # (not called in Rails 3 and later!)
  def recognize_path( path, options)
    # must turn our arguments into a Request and then call Merb::Router.route_for(request)
    # In Rails, this routine calls recognize_optimized(path, environment). Unfortunately (or fortunately) Merb
    # routing defines no such method. Merb routing matches request objects against routes.

    # get the Rails Rack app per these instructions http://guides.rubyonrails.org/rails_on_rack.html#rails-applications-rack-object
    app = ActionController::Dispatcher.new

    s = Rack::Test::Session.new( app ) # create the rack-test session
    
    # if we rec'd the HTTP method as a symbol, better make sure it's a string for env_for
    options[:method] = options[:method].to_s
    
    # now stick our hand up inside rack-test, not because we _want_ to mind you, but because we _have_ to (as usual)
    env = s.instance_eval{  env_for path, options }
    
    # borrowed from Rack::Test::Session#process_request (we don't actually want to _process_ this request—
    # only build its Request object)
    
    # request = Rack::Request.new(env)
    
    # oh but that Rack request isn't exactly what we need, no! And furthermore, it looks like merb_routing plugin
    # doesn't bring along Merb's own Request object (makes sense since we're integrating with Rails). So we'll create
    # a Rails request (which is a subclass of Rack::Request). Now from a read of that class I see no initialize, so I 
    # assume I can construct an instance exactly the way I construct an instance of the base class...
    # (note that Request moves into ActionDispatch in Rails 3)
    request = ActionController::Request.new( env )
    
    # make the request
    begin
      route_and_params = merb_route_for( request )
    rescue ActionController::RoutingError
      # gotta avoid letting that error bubble up lest we break the caller!
    end
    elide_blank_format( route_and_params.blank? ? {} : route_and_params[1] )
  end

  # given a request object, this matches a route, sets route/path_parameters, and returns the controller class
  def recognize(request)
    request.route, params = merb_route_for(request)
    request.path_parameters = elide_blank_format( params.with_indifferent_access )
    "#{request.path_parameters[:controller].camelize}Controller".constantize
  end

  def call(env)
    request = ActionController::Request.new(env)
    app = ActionController::Routing::Routes.recognize(request)
    app.call(env).to_a
  end

  # given a hash of params, this determines the best route for us
  def generate(options, recall={})
    merged_options = recall.merge(options).reject { |k,v| v.nil? }

    if options[:use_route]
      best_route = Merb::Router.named_routes[options.delete(:use_route)]
    else
      best_route = nil
      best_score = 0

      routes_for_controller_and_action(merged_options[:controller], merged_options[:action]).map do |route|
        score = route.params.reject { |k,v| !((v =~ /^"(.*)"$/ && merged_options[k] == $1) || (v =~ /^\((.*)\)$/ && merged_options.has_key?(k))) }.length
        best_score, best_route = score, route if score > best_score
      end
    end
    @keys_we_dont_need = best_route.params.reject { |k,v| !(v =~ /^"(.*)"$/ && merged_options[k] == $1) }.keys
    nonredundant_options = options.reject { |k,v| @keys_we_dont_need.include?(k) }

    best_route.generate([nonredundant_options], recall)
  end

  def routes_for_controller_and_action(controller, action)
    action = action.to_s
    @routes_by_controller ||= {}
    @routes_by_controller[controller] ||= {}
    @routes_by_controller[controller][action] ||= Merb::Router.routes.reject { |route| (route.params[:controller] =~ /^"(.*)"$/ && $1 != controller) || (route.params[:action] =~ /^"(.*)"$/ && $1 != action) }
  end

  # rspec-rails needs this to be defined.
  # description from Rails doc: Generate the path indicated by the arguments, and return 
  # an array of the keys that were not used to generate it.
  def empty?
    Merb::Router.routes.empty?
  end
  
  # rspec-rails also needs this one to be defined
  def extra_keys(hash, recall={})
    generate( hash, recall) # called for side-effect: set @keys_we_dont_need
    @keys_we_dont_need  - [:controller, :action] # it seems we always need controller and action
  end
  
  private

  # to make rspec specs work right we need to elide :format => nil otherwise we fail all of our params_for and route_for specs
  def elide_blank_format( params)
    params.delete(:format) if params[:format].blank?
    params
  end
  
  def merb_route_for( request )
    Merb::Router.route_for(request)
  rescue NoMethodError
    # we catch an error here when no route is found. Merb routing is trying to invoke _process_block_return
    # on the request at that point but since that method is defined on Merb::Request and not on Rails' request
    # class, naturally it's not defined.
    #
    #   <NoMethodError: undefined method `_process_block_return' for #<ActionController::Request:0x403d2e4>>
    #
    # Anyhoo, we need to catch and convert it into what Rails expects. Failure to do this wrecks negative test cases
    # especially (negative specs)
    raise ActionController::RoutingError, "no route found to match\n #{ capture { y request } }"
  end
end

# automatically use :to_params or :id on active record objects
Merb::Router::Route.class_eval do
  def identifier_for_with_active_record(obj)
    case
      when obj.respond_to?(:to_param) then :to_param
      when obj.is_a?(ActiveRecord::Base) then :id
      else identifier_for_without_active_record(obj)
    end
  end
  alias_method_chain :identifier_for, :active_record
end

# set the Routes object to our wrapper
silence_warnings { ActionController::Routing::Routes = ActionController::Routing::MerbRoutingWrapper.new }

# merb calls request.uri sometimes... map it to request_uri
ActionController::Request.class_eval { alias :uri :request_uri }
  
# store the route we ended up recognizing so we can use url(:this)
ActionController::Request.class_eval { attr_accessor :route }
