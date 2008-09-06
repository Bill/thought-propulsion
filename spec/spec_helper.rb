# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  
  #
  # I wish I didn't have to do this but for now it's necessary to avoid errors like this when 
  # running rake spec:lib:
  # SQLite3::SQLException in 'DomainName domain name validator should reject invalid labels like one with an uppercase character'
  # SQL logic error or missing database
  #
  # See:
  # http://havegnuwilltravel.apesseekingknowledge.net/2008/01/rspeconrails-sqlite3-error.html
  # http://www.nabble.com/Re%3A-An-error-on-edge-at--r-2767-p13370152.html
  #
  config.use_transactional_fixtures = false
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
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

# Make this a class so we can instantiate it and apply with_options to it :)
module Site

  module ExampleGroupExtensions
    def subs( domain)
      [domain, "dev.#{domain}", "staging.#{domain}"]
    end
    def for_subdomains( domain)
      subs( domain).each do | d |
        with_options( :host => d) do | site |
          yield site, d
        end
      end
    end
  end

  module ExampleExtensions
    def route( path, options)
      begin
        result = ActionController::Routing::Routes.recognize_path( path, options)
      rescue ActionController::RoutingError
      end
      result
    end
  end
end

require 'ruby-debug'
Debugger.start

# Thanks to: http://blog.nicksieger.com/articles/2007/01/02/customizing-rspec
# it was out of date but got me on the right track
module Spec::Example::ExampleGroupMethods
  def before_eval
    extend Site::ExampleGroupExtensions
    include Site::ExampleExtensions
  end
end