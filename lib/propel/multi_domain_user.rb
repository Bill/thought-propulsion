require 'propel/multi_domain_user/extract_published_as_alternate_twipl_domain_parameter'

# can't patch RouteSet class -- it's too late. so we patch the instance…
class <<ActionController::Routing::Routes
  include Propel::MultiDomainUser::ExtractUserForAlternateDomainParameter
end
