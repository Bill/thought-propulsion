# TODO: remove both of these (hash, option_merger) once I'm on the next (post 2.1.0) Rails release
# the extensions directory contains non-controversial Rails
# extensions that the rest of our monkey-patches rely on
require 'propel/multi_domain_routing/extensions/hash'
require 'propel/multi_domain_routing/extensions/option_merger'

class Hash
  include ActiveSupport::CoreExtensions::Hash::DeepMerge
end