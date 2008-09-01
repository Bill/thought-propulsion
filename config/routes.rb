# Since we qualify all our routes on domain patterns, we cannot simply define shared routes at the top
# of the route set. Instead we have this function we can call in the context of each with_options block
# to define the universal routes for each context.
module Propel::UniversalRoutes
  # I would have liked to just defined this method on map object below but unfortunately that won't play with
  # with_options since ActiveSupport::OptionMerger has already done its magic to the RouteSet class (I'm too late!)
  def define_universal_routes( map)
    map.login 'login', :controller => 'home'
    map.logout 'logout', :controller => 'openids', :action => 'logout'
    map.profile 'profile', :controller => 'users', :action => 'profile'
    map.resource :openid, :member => { 
      :logout => :get,
      :openid_authentication_callback => :get }
    map.resources :users
    map.resource :stylesheets do |stylesheet|
      stylesheet.resource :application, :controller => 'application_stylesheet'
    end
    # these three actions are solely for testing the HTML/CSS layout of the alert div
    map.error 'error/:msg', :controller => 'home', :action => 'error'
    # can't call this 'warn' because it conflicts w/ some Rails method somewhere
    map.warning 'warn/:msg', :controller => 'home', :action => 'warn'
    map.inform 'inform/:msg', :controller => 'home', :action => 'inform'
  end
  module_function :define_universal_routes
end

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  # blog.thoughtpropulsion.com is a special case since it's powered by twipl but lives under
  # the thoughtpropulsion.com domain
  map.with_options :conditions => { :host => /^blog\.(((dev)|(staging))\.)?thoughtpropulsion.com$/}, :layout => 'home' do | blog |
    blog.connect '', :controller => 'twips'
    Propel::UniversalRoutes.define_universal_routes( blog)
  end

  map.with_options :conditions => { :host => /^(((www)|(dev)|(staging))\.)?thoughtpropulsion.com$/}, :layout => 'home' do | thoughtpropulsion |
    thoughtpropulsion.home '', :controller => 'home'
    thoughtpropulsion.why 'why', :controller => 'about', :action => 'index'
    thoughtpropulsion.contact 'contact', :controller => 'contact', :action => 'index'
    Propel::UniversalRoutes.define_universal_routes( thoughtpropulsion)
  end
  
  map.with_options :conditions => { :host => /^(((www)|(dev)|(staging))\.)?twipl.com$/}, :layout => 'twipl_home' do | twipl |
    twipl.home '', :controller => 'twipl_home'
    twipl.resources :twips, :collection => { :service_document => :get}
    Propel::UniversalRoutes.define_universal_routes( twipl)
  end
  
  # custom domains under twipl.com as well as foreign domain mappings (for twipl)
  # This is where the public comes to read posts authored by twipl users.
  # So we want to map the twipl listing to the root so readers don't have to go to /twips
  map.with_options :conditions => { :host => /(.+\.)twipl.com$/}, :layout => 'twipl_home' do | twiplpowered |
    twiplpowered.connect '', :controller => 'twips'
    Propel::UniversalRoutes.define_universal_routes( twiplpowered)
  end

  # Do not install the default routes at all since that would cause e.g. a request to 
  # http://twipl.com/contact to route to the contacts controller.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
