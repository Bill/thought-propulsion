require 'spec/autorun'
require 'spec/rails'

# This (monkey-patch of rspec example groups with this module) is a backward-compatible change that lets old specs 
# (which do not specify options) work and also allows new specs which need to specify options work too 
# e.g. params_from( :get, '/froobles', :host => 'www.example.com' )
module ParamsFromWithOptions
  # # simulates extract_request_environment hook on Rails routing and generally gives spec's the ability
  # # to set all kinds of request environment options (in Rails routing or Merb routing)
  # def params_from( method, path, options = {} )
  #   ensure_that_routes_are_loaded
  #   ActionController::Routing::Routes.recognize_path(path, {:method => method}.merge!( options ) )
  # rescue ActionController::RoutingError # swallow these and return nil
  # end
  
  def params_from(method, path, options = {})
    ensure_that_routes_are_loaded
    path, querystring = path.split('?')
    params = ActionController::Routing::Routes.recognize_path( path || '', {:method => method}.merge!( options ))
    querystring.blank? ? params : params.merge(params_from_querystring(querystring))
  end
  
end
module Spec
  module Rails
    module Example
      class ControllerExampleGroup
        include ParamsFromWithOptions
      end
      class RoutingExampleGroup
        include ParamsFromWithOptions
      end
    end
  end
end