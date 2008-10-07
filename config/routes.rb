envsub, port = Propel::EnvironmentSubdomains::envsub
envsub = Regexp.escape(envsub) # we're gonna use envsub as part of a Regexp

# Since we qualify all our routes on domain patterns, we cannot simply define shared routes at the top
# of the route set. Instead we have this function we can call in the context of each with_options block
# to define the universal routes for each context.
module Propel::UniversalRoutes
  # I would have liked to just defined this method on map object below but unfortunately that won't play with
  # with_options since ActiveSupport::OptionMerger has already done its magic to the RouteSet class (I'm too late!)
  def define( map)
    map.connect '', :controller => 'home', :action => 'index', :conditions => {:method => :get}    
    map.connect 'login', :controller => 'home', :action => 'index', :conditions => {:method => :get}
    map.connect 'logout', :controller => 'openids', :action => 'logout', :conditions => {:method => :get}
    map.connect 'profile', :controller => 'users', :action => 'profile', :conditions => {:method => :get}

    # gotta explicitly define each (REST) route in order ot inherit stuff set by with_options
    # see RCB's comments here: http://weblog.jamisbuck.org/2007/1/24/object-with_options

    # map.resource :openids
    map.connect '/openids/new', :controller=>'openids', :action=>'new', :conditions => {:method => :get}
    map.connect '/openids', :controller=>'openids', :action=>'create', :conditions => {:method => :post}
    map.connect '/openids/openid_authentication_callback', :controller => 'openids', :action => 'openid_authentication_callback', :conditions => { :method => :get}
    map.connect '/users/new', :controller=>'users', :action=>'new', :conditions => {:method => :get}
    map.connect '/users', :controller=>'users', :action=>'create', :conditions => {:method => :post}
    map.connect '/users/:id/edit', :controller=>'users', :action=>'edit', :conditions => {:method => :get}
    map.connect '/users/:id', :controller=>'users', :action=>'show', :conditions => {:method => :get}
    map.connect '/users/:id', :controller=>'users', :action=>'update', :conditions => {:method => :put}
    map.connect '/users', :controller=>'users', :action=>'index', :conditions => {:method => :get}
      
    # map.resource :stylesheets do |stylesheet|
    #   stylesheet.resource :application, :controller => 'application_stylesheet'
    # end
    map.connect 'stylesheets/application.css', :controller => 'application_stylesheet', :action => 'show', :format => 'css', :conditions => {:method => :get}
    
    # these three actions are solely for testing the HTML/CSS layout of the alert div
    map.connect 'error/:msg', :controller => 'home', :action => 'error', :conditions => {:method => :get}
    # can't call this 'warn' because it conflicts w/ some Rails method somewhere
    map.connect 'warn/:msg', :controller => 'home', :action => 'warn', :conditions => {:method => :get}
    map.connect 'inform/:msg', :controller => 'home', :action => 'inform', :conditions => {:method => :get}
  end
  module_function :define
end

module Propel::TwiplRoutes
  def define( map)
    # map.resources :twips, :collection => { :service_document => :get}
    map.connect 'twips/service_document', :controller => 'twips', :action => 'service_document', :conditions => { :method => 'get'}
    map.connect '/twips/new', :controller=>'twips', :action=>'new', :conditions => {:method => :get}
    map.connect '/twips', :controller=>'twips', :action=>'create', :conditions => {:method => :post}
    map.connect '/twips/:id/edit', :controller=>'twips', :action=>'edit', :conditions => {:method => :get}
    map.connect '/twips/recent', :controller=>'days', :action=>'index', :conditions => {:method => :get}
    map.connect '/twips/:id', :controller=>'twips', :action=>'show', :conditions => {:method => :get}
    map.connect '/twips/:id', :controller=>'twips', :action=>'update', :conditions => {:method => :put}
    map.connect '/twips', :controller=>'twips', :action=>'index', :conditions => {:method => :get}
  end
  module_function :define
end

ActionController::Routing::Routes.draw do |map|
  
  # The priority is based upon order of creation: first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  # blog.thoughtpropulsion.com is a special case since it's powered by twipl but lives under
  # the thoughtpropulsion.com domain
  map.with_options :conditions => { :host => /^blog\.#{envsub}thoughtpropulsion.com$/} do | blog |
    blog.connect '', :controller=>'days', :action=>'index', :conditions => {:method => :get}
    blog.connect '/twips/:id', :controller=>'twips', :action=>'show', :conditions => {:method => :get}
    Propel::UniversalRoutes.define( blog)
  end

  map.with_options :conditions => { :host => /^#{envsub}thoughtpropulsion.com$/} do | thoughtpropulsion |
    thoughtpropulsion.connect '', :controller => 'home', :action => 'index', :conditions => {:method => :get}
    thoughtpropulsion.connect 'why', :controller => 'about', :action => 'index', :conditions => {:method => :get}
    thoughtpropulsion.contact 'contact', :controller => 'contact', :action => 'index', :conditions => {:method => :get}
    Propel::UniversalRoutes.define( thoughtpropulsion)
  end
  
  map.with_options :conditions => { :host => /^#{envsub}twipl.com$/} do | twipl |
    twipl.connect '', :controller => 'twipl_home', :action => 'index', :conditions => {:method => :get}
    
    Propel::TwiplRoutes.define( twipl)
    Propel::UniversalRoutes.define( twipl)
  end
  
  # custom domains under twipl.com as well as foreign domain mappings (for twipl)
  # This is where the public comes to read posts authored by twipl users.
  # So we want to map the twipl listing to the root so readers don't have to go to /twips
  map.with_options :conditions => { :host => /(.+\.)#{envsub}twipl.com$/} do | twipl_powered |
    twipl_powered.connect '', :controller=>'days', :action=>'index', :conditions => {:method => :get}
    Propel::TwiplRoutes.define( twipl_powered)
    Propel::UniversalRoutes.define( twipl_powered)
  end
  
  # third-party domains powered by twipl
  map.with_options :conditions => { :published_as_alternate_twipl_domain => true } do | twipl_powered_3p |
    twipl_powered_3p.connect '', :controller=>'days', :action=>'index', :conditions => {:method => :get}
    Propel::TwiplRoutes.define( twipl_powered_3p)
    Propel::UniversalRoutes.define( twipl_powered_3p)
  end

  # Do not install the default routes at all since that would cause e.g. a request to 
  # http://twipl.com/contact to route to the contacts controller.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
