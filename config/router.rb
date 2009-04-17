envsub, port = Propel::EnvironmentSubdomains::envsub
envsub = Regexp.escape(envsub) # we're gonna use envsub as part of a Regexp

module RequestMethods
  # boolean: is the current request on a domain that a Twipl users has registered as an alternate domain?
  def alternate_domain
    !! User.for_host( host).find(:first)
  end
end
module ActionController
  Request.class_eval "include(RequestMethods)"
end

# FIXME: the need to have the explicit block parameter "r" is already deprecated in merb core but my plugin uses
# an older version of merb. Remove all these r's and r.'s once we're up to date.
Merb::Router.prepare do |r|
  
  Merb::Router.extensions do
    
    def openids(r)
      r.defaults( :controller => 'openids') do
        r.match( '/logout', :method => 'get').
          to( :action => 'logout').name('logout')
        r.match( '/openids') do | openids |
          openids.match( '/logout', :method => 'get').
            to( :action => 'logout')
          openids.match( '/new', :method => 'get').
            to( :action => 'new')
          openids.match( '', :method => 'post').
            to( :action => 'create')
          openids.match( '/openid_authentication_callback', :method => 'get').
            to( :action => 'openid_authentication_callback')
        end
      end
    end
    
    def users(r)
      r.default( :controller => 'users') do
        r.match( '/profile', :method => 'get').
          to( :action => 'profile')
        r.match( '/users') do | users |
          users.match('/:id', :method => 'get').
            to( :action => 'show')
          users.match('/:id', :method => 'put').
            to( :action => 'update')
          users.match('/:id/edit', :method => 'get').
            to( :action => 'edit')
          users.match('/new', :method => 'get').
            to( :action => 'new')
          users.match( '', :method => 'post').
            to( :action => 'create')
        end
      end
    end

    def twipl(r)      
      r.match('/', :method => 'get').
        to( :controller => 'twipl_home', :action => 'index').
          name( :twipl_home)
    end
    
    def twipl_authenticated(r)
      # TODO: make login (form) an action on openids_controller and move this route to openids above
      r.match( '/login', :method => 'get').
        to( :controller => 'twipl_home', :action => 'index').name('login')
      r.default( :controller => 'twips') do
        r.match( '/twips') do | twips |
          twips.match('/new', :method => 'get').
            to( :action => 'new')
          twips.match('', :method => 'post').
            to( :action => 'create')
          twips.match('/:id/edit', :method => 'get').
            to( :action => 'edit')
          twips.match('/:id', :method => 'put').
            to( :action => 'update')
        end
      end
      r.default( :controller => 'images') do
        r.match( '/images') do | images |
          images.match('/new', :method => 'get').
            to( :action => 'new')
          images.match('/create', :method => 'post').
            to( :action => 'create')
        end
      end
      r.match('/image_placements/create_json', :method => 'post').
        to( :controller => 'image_placements', :action => 'create_json')
    end
    
    def twipl_syndicated(r)
      r.default( :controller => 'twips') do
      # * odd * in order to have / and /.atom match at this level I must match '/(.:format)' yet
      # to match /twips and /twips/.atom I must match '(/.:format)' under /twips (see twips block below)
      r.match('/(.:format)', :method => 'get').
        to( :action => 'index').
          name( :twips_index)
        r.match( '/twips') do | twips |
          twips.match('(/.:format)', :method => 'get').
            to( :action => 'index').name('twips')
          twips.match( '/:id', :method => 'get').
            to( :action => 'show').name('twip')
        end
      end
      r.match('/images/:id', :method => 'get').
        to( :controller => 'images', :action => 'show')
      r.match('/image_placements/:id', :method => 'get').
        to( :controller => 'image_placements', :action => 'show').name('image_placement')
    end
  end

  
  # ----------------------------------------------------------
  # all applications get these rules
  #
  r.match('/stylesheets/application.css', :method => 'get').
    to( :controller => 'stylesheets', :action => 'application').
      name( :application_stylesheet)
  r.match('/swatches', :method => 'get').
    to( :controller => 'swatches', :action => 'index')
  
  # ----------------------------------------------------------
  # Thought Propulsion(TM) home rules
  #
  r.match( :host => /^www\.#{envsub}thoughtpropulsion\.com$/) do
    r.match('/', :method => 'get').
      to( :controller => 'home', :action => 'index', :foo => 'BAR').
        name( :home)
    r.match('/why', :method => 'get').
      to( :controller => 'about', :action => 'index').
        name( :why)
    r.match('/contact', :method => 'get').
      to( :controller => 'contact', :action => 'index').
        name( :contact)
  end

  # ----------------------------------------------------------
  # Twipl home
  #
  r.match( :host => /^www\.#{envsub}twipl\.com$/) do
    twipl( r )
  end

  # ----------------------------------------------------------
  # Twipl-Powered(TM) free domain (subdomain of twipl.com)
  #
  r.match( :host => /^.+#{envsub}twipl\.com$/) do
    openids( r )
    users( r )
    twipl_authenticated( r )
    twipl_syndicated( r )
  end
  
  # ----------------------------------------------------------
  # Twipl-Powered(TM) third-party domain
  #
  r.match( :alternate_domain => true) do
    openids( r )
    users( r )
    twipl_authenticated( r )
    twipl_syndicated( r )
  end

  
  # ----------------------------------------------------------
  # Catch-all. Uncomment for debugging.
  #  
  # r.defer_to do | request, params |
  #   debugger
  #   x = 1
  # end
  
end