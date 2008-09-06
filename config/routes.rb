# Since we qualify all our routes on domain patterns, we cannot simply define shared routes at the top
# of the route set. Instead we have this function we can call in the context of each with_options block
# to define the universal routes for each context.
module Propel::UniversalRoutes
  # I would have liked to just defined this method on map object below but unfortunately that won't play with
  # with_options since ActiveSupport::OptionMerger has already done its magic to the RouteSet class (I'm too late!)
  def define( map)
    map.login 'login', :controller => 'home', :conditions => {:method => :get}
    map.logout 'logout', :controller => 'openids', :action => 'logout', :conditions => {:method => :get}
    map.profile 'profile', :controller => 'users', :action => 'profile', :conditions => {:method => :get}

    # gotta explicitly define each (REST) route in order ot inherit :layout set by with_options
    # see RCB's comments here: http://weblog.jamisbuck.org/2007/1/24/object-with_options

    # map.resource :openids
    map.new_openid '/openids/new', :controller=>'openids', :action=>'new', :conditions => {:method => :get}
    map.create_openid '/openids', :controller=>'openids', :action=>'create', :conditions => {:method => :post}
    map.openid_callback '/openids/openid_authentication_callback', :controller => 'openids', :action => 'openid_authentication_callback', :conditions => { :method => :get}
    map.user '/users/:id', :controller=>'users', :action=>'show', :conditions => {:method => :get}
    map.new_user '/users/new', :controller=>'users', :action=>'new', :conditions => {:method => :get}
    map.create_user '/users', :controller=>'users', :action=>'create', :conditions => {:method => :post}
    map.edit_user '/users/:id/edit', :controller=>'users', :action=>'edit', :conditions => {:method => :get}
    map.update_user '/users/:id', :controller=>'users', :action=>'update', :conditions => {:method => :put}
    map.list_users '/users', :controller=>'users', :action=>'index', :conditions => {:method => :get}
      
    map.resource :stylesheets do |stylesheet|
      stylesheet.resource :application, :controller => 'application_stylesheet'
    end
    
    # these three actions are solely for testing the HTML/CSS layout of the alert div
    map.error 'error/:msg', :controller => 'home', :action => 'error', :conditions => {:method => :get}
    # can't call this 'warn' because it conflicts w/ some Rails method somewhere
    map.warning 'warn/:msg', :controller => 'home', :action => 'warn', :conditions => {:method => :get}
    map.inform 'inform/:msg', :controller => 'home', :action => 'inform', :conditions => {:method => :get}
  end
  module_function :define
end

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # See how all your routes lay out with "rake routes"

  # blog.thoughtpropulsion.com is a special case since it's powered by twipl but lives under
  # the thoughtpropulsion.com domain
  map.with_options :conditions => { :host => /^blog\.(((dev)|(staging))\.)?thoughtpropulsion.com$/}, :layout => 'home' do | blog |
    blog.home '', :controller => 'twips'
    Propel::UniversalRoutes.define( blog)
  end

  map.with_options :conditions => { :host => /^(((www)|(dev)|(staging))\.)?thoughtpropulsion.com$/}, :layout => 'home' do | thoughtpropulsion |
    thoughtpropulsion.home '', :controller => 'home'
    thoughtpropulsion.why 'why', :controller => 'about', :action => 'index'
    thoughtpropulsion.contact 'contact', :controller => 'contact', :action => 'index'
    Propel::UniversalRoutes.define( thoughtpropulsion)
  end
  
  map.with_options :conditions => { :host => /^(((www)|(dev)|(staging))\.)?twipl.com$/}, :layout => 'twipl_home' do | twipl |
    twipl.home '', :controller => 'twipl_home'
    twipl.resources :twips, :collection => { :service_document => :get}
    Propel::UniversalRoutes.define( twipl)
  end
  
  # custom domains under twipl.com as well as foreign domain mappings (for twipl)
  # This is where the public comes to read posts authored by twipl users.
  # So we want to map the twipl listing to the root so readers don't have to go to /twips
  map.with_options :conditions => { :host => /(.+\.)twipl.com$/}, :layout => 'twipl_home' do | twipl_powered |
    twipl_powered.home '', :controller => 'twips'
    Propel::UniversalRoutes.define( twipl_powered)
  end
  
  # third-party domains powered by twipl
  map.with_options :layout => 'twipl_home' do | twipl_powered_3p |
    twipl_powered_3p.home '', :controller => 'twips'
    Propel::UniversalRoutes.define( twipl_powered_3p)
  end

  # Do not install the default routes at all since that would cause e.g. a request to 
  # http://twipl.com/contact to route to the contacts controller.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
