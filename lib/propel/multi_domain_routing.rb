require 'propel/multi_domain_routing/extensions'

require 'propel/multi_domain_routing/extract_host_parameter'
require 'propel/multi_domain_routing/inject_host_parameter_into_url_generation'
require 'propel/multi_domain_routing/multiple_routes_per_name'
require 'propel/multi_domain_routing/capture_generate_options'

# can't patch RouteSet class -- it's too late. so we patch the instance…
class <<ActionController::Routing::Routes
  include Propel::MultiDomainRouting::ExtractHostParameter
end

class ActionController::AbstractRequest
  include Propel::MultiDomainRouting::InjectHostParameterIntoURLGeneration
end

class <<ActionController::Routing::Routes.named_routes
  include Propel::MultiDomainRouting::MultipleRoutesPerName
end

class <<ActionController::Routing::Routes
  include Propel::MultiDomainRouting::CaptureGenerateOptions
end

