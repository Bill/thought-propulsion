# Add :host variable extraction to Dan Webb's request_routing plugin
module Propel
  module MultiDomainRouting
    # include this module in RouteSet after request_routing plugin is loaded
    module ExtractHostParameter
      def self.included( other)
        other.alias_method_chain :extract_request_environment, :host

        # patch corresponding matcher
        ActionController::Routing::Route::TESTABLE_REQUEST_METHODS << :host
      end
      
      def extract_request_environment_with_host( request )
        extract_request_environment_without_host( request ).merge :host => request.host
      end
    end
  end
end