# Add :published_as_alternate_twipl_domain variable extraction to Dan Webb's request_routing plugin
module Propel
  module MultiDomainUser
    module ExtractUserForAlternateDomainParameter
      # include this module in RouteSet after request_routing plugin is loaded
      def self.included( other)
        other.alias_method_chain :extract_request_environment, :published_as_alternate_twipl_domain

        # patch corresponding matcher
        ActionController::Routing::Route::TESTABLE_REQUEST_METHODS << :published_as_alternate_twipl_domain
      end

      def extract_request_environment_with_published_as_alternate_twipl_domain( request )
        extract_request_environment_without_published_as_alternate_twipl_domain( request ).merge :published_as_alternate_twipl_domain => !! User.for_host( request.host).find(:first)
      end
    end
  end
end