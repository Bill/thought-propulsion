module Propel
  module EnvironmentSubdomains

    # Given the Rails environment, determine which subdomain and port apply
    def envsub
      case ENV['RAILS_ENV']
      when 'development'
        ['dev.', 3000]
      when 'staging'
        ['staging.', nil]
      else # production and test
        ['', nil]
      end
    end
    module_function :envsub
    
  end
end