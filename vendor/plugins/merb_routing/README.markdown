# MerbRouting #

This plugin allows you to use Merb routing in a Ruby on Rails project.

See the [announcement](http://blog.hungrymachine.com/2008/12/29/merb-routing-in-rails/) at [HungryMachine](http://blog.hungrymachine.com/)

## Compatibility ##

Ruby on Rails version 2.3.2 thanks to [Piotr Sarnacki](http://drogomir.com/blog)

Support for rspec-rails and Cucumber thanks to [Bill Burcham](http://blog.thoughtpropulsion.com)

## Integrating with Rspec-Rails ##

Put this in your Spec::Runner.configure block in spec_helper.rb

    config.include ActionController::Routing::Helpers, Merb::Router::UrlHelpers
   
## What Works ##

It looks like routing and URL generation work in running apps and in rspec specs. Both route\_for and params\_from work fine when called from rspec examples. So this will work (in a Rails project that includes this plugin):

    script/generate rspec_scaffold Frooble name:string color:string description:text
    rake db:migrate
    rake spec
    
That's testing model, controller and routes.

Cucumber stories work too, so:

    ruby script/generate feature Frooble name:string color:string description:text
    rake features
    
Works.

## Dependencies ##

Requires the rack-test gem:

    sudo gem install rack-test

In environment.rb:

    config.gem 'rack-test', :lib => 'rack/test'

## License ##
[MIT License](MIT-LICENSE)