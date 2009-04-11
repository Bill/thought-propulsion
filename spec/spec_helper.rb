# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'

# Inject request information for route recogition
# based on Olivier El Mekki's (http://blog.olivier-elmekki.com/) comment here (http://www.smallroomsoftware.com/articles/2007/2/10/rails-routing-based-on-hostname)
module Spec
  module Rails
    module Example
      class ControllerExampleGroup
        # simulates extract_request_environment hook
        def params_from( method, path, options )
          ensure_that_routes_are_loaded
          ActionController::Routing::Routes.recognize_path(path, {:method => method}.merge!( options ) )
        rescue ActionController::RoutingError # swallow these and return nil
        end
      end
    end
  end
end

module Site

  module ExampleExtensions
    
    # FIXME: this doesn't work yet
    def generate(options, recall = {:controller=>'users', :action=>'index', :layout=>'home', :host=>'thoughtpropulsion.com'})
      controller_string = @controller_class_name.tableize.split('_')[0..-2].join('_')
      # TODO: handle recall options
      new_options = {:controller => controller_string}.merge( options )
      Action:Controller::Routing::Routes.generate( new_options, recall)
      # route_for( {:controller => controller_string}.merge( options ) )
    end
  end
end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  
  config.mock_with :mocha
  
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
  
  config.include Site::ExampleExtensions
end
