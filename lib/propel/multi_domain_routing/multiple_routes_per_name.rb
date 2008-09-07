module Propel
  module MultiDomainRouting
    module MultipleRoutesPerName
      def self.included( other)
        other.alias_method_chain :add, :multiple_routes_per_name
        other.alias_method_chain :get, :multiple_routes_per_name
        alias []= add_with_multiple_routes_per_name
        alias [] get_with_multiple_routes_per_name
      end
      
      def add_with_multiple_routes_per_name(name, route)
        # Don't call original add with new route, not new_value -- careful here!
        # it'd just go and call RouteSet#define_named_route_methods doh!
        # replicate the innards of RouteSet::NamedRouteCollection::add…
        old_value = get_without_multiple_routes_per_name( name)
        new_value = case old_value
        when nil
          define_named_route_methods(name, route)
          route
        when ActionController::Routing::Route: [ old_value, route ]
        when Array: old_value << route
        else
          raise "MultiDomainRouting expected named route table to contain Routes or Arrays of Routes"
        end
        routes[name.to_sym] = new_value
      end
      
      def get_with_multiple_routes_per_name(name)
        value = get_without_multiple_routes_per_name( name)
        case value
        when nil: nil
        when ActionController::Routing::Route: value
        when Array
          return value.first
          # TODO make this work
          # OK here we go, we have to disambiguate this named route. Let's do it…
          value.find do | route |
            # match = route.generate( options, merged, expire_on)
            # Notice, we're calling a method that we have defined on Route (see RouteRecognizeWithoutPath)
            # TODO: this brings up the important issue that we should be doing this sort of recognition
            # during URL generation, not just for named routes but for all routes!
            # see our CaptureGenerateOptions patch--it stashes the generate options for us
            
            # use parameter_shell as defaults 
            options = route.parameter_shell.merge( ActionController::Routing::Routes.current_generate_options )
            recall = route.parameter_shell.merge( ActionController::Routing::Routes.current_request_options )
            params = route.generate( options, recall)
            # this logic is stolen directly from RouteSet#generate but instead of returning "match" we return
            # the corresponding route
            params && (!params.is_a?(Array) || params.first)
          end
        else
          raise "MultiDomainRouting expected named route table to contain Routes or Arrays of Routes"
        end
      end
    end
  end
end