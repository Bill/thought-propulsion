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

  # Send the bare URL to the home/index
  map.home '', :controller => 'home'
  
  # these three actions are solely for testing the HTML/CSS layout of the alert div
  map.error 'error/:msg', :controller => 'home', :action => 'error'
  map.error 'warn/:msg', :controller => 'home', :action => 'warn'
  map.error 'inform/:msg', :controller => 'home', :action => 'inform'
  
  map.why 'why', :controller => 'about', :action => 'index'
  map.contact 'contact', :controller => 'contact', :action => 'index'
  
  map.logout 'logout', :controller => 'openids', :action => 'logout'

  map.resource :openid, :member => { :logout => :get }
  
  map.resources :users
  
  map.resource :stylesheets do |stylesheet|
    stylesheet.resource :application, :controller => 'application_stylesheet'
  end

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
