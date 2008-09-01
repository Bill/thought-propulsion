ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  map.login 'login', :controller => 'home'
  map.logout 'logout', :controller => 'openids', :action => 'logout'

  map.resource :openid, :member => { 
    :logout => :get,
    :openid_authentication_callback => :get }
  
  map.resources :users

  map.resource :stylesheets do |stylesheet|
    stylesheet.resource :application, :controller => 'application_stylesheet'
  end

  # these three actions are solely for testing the HTML/CSS layout of the alert div
  map.error 'error/:msg', :controller => 'home', :action => 'error'
  map.warn 'warn/:msg', :controller => 'home', :action => 'warn'
  map.inform 'inform/:msg', :controller => 'home', :action => 'inform'

  # blog.thoughtpropulsion.com is a special case since it's powered by twipl but lives under
  # the thoughtpropulsion.com domain
  map.with_options :conditions => { :host => /^blog.thoughtpropulsion.com$/} do | blog |
    blog.connect '', :controller => 'twips'
  end

  map.with_options :conditions => { :host => /(.+\.)?thoughtpropulsion.com$/} do | thoughtpropulsion |
    thoughtpropulsion.home '', :controller => 'home'
    thoughtpropulsion.why 'why', :controller => 'about', :action => 'index'
    thoughtpropulsion.contact 'contact', :controller => 'contact', :action => 'index'
  end
  
  map.with_options :conditions => { :host => /(.+\.)?twipl.com$/} do | twipl |
    twipl.home '', :controller => 'twipl_home'
    twipl.resources :twips, :collection => { :service_document => :get}
  end
  
  # custom domains under twipl.com as well as foreign domain mappings (for twipl)
  # This is where the public comes to read posts authored by twipl users.
  # So we want to map the twipl listing to the root so readers don't have to go to /twips
  map.connect '', :controller => 'twips'
  

  # Do not install the default routes at all since that would cause e.g. a request to 
  # http://twipl.com/contact to route to the contacts controller.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
