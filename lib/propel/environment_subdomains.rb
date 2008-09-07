module Propel
  module EnvironmentSubdomains

    # Given the Rails environment, determine which subdomain and port apply
    def envsub
      case ENV['RAILS_ENV']
      when 'development', 'test'
        ['dev.', 3000]
      when 'staging'
        ['staging.', nil]
      else
        ['', nil]
      end
    end
    module_function :envsub
    
  end
end