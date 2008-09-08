# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include Authentication
  include Authorization
  include Alert
  
  helper :all # include all helpers, all the time
  
  before_filter :load_user
  before_filter :page_title

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '75d37e2b85a64152386bd5be91124174'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  # has to be public so it is accessible in the layout (class) method of our subclasses
  def layout
    envsub, port = Propel::EnvironmentSubdomains::envsub
    envsub = Regexp.escape(envsub) # we're gonna use envsub as part of a Regexp
    
    # These patterns must match routes.rb
    case request.host
    when /^blog\.#{envsub}thoughtpropulsion.com$/, /^#{envsub}thoughtpropulsion.com$/: 'home'
    when /^#{envsub}twipl.com$/, /(.+\.)#{envsub}twipl.com$/: 'twipl_home'
    else
      'twipl_home'
    end
  end
  
  protected
  
  # We sometimes interrupt the user's flow to require a login (or registration). Rather than blindly
  # redirecting to e.g. home after that, if the user was going somewhere to start with, then redirect her
  # there
  # FIXME: url helper
  def redirect_to_original_destination( default_destination = url_for( '/' ) )
    redirect_to session[:return_to] || default_destination
    session[:return_to] = nil # I know no other way to "clear" a slot in the session!
  end
  
  # override in subclasses to append a controller-specific tail onto the site-specific head of the page title
  def page_title
    ''
  end
  
  helper_method :page_title
  
  def registered_user
    @registered_user
  end
  
  helper_method :registered_user

  private

  def load_user
      @registered_user = User.with_same_identity( User.new { |user| user.identity_url = session[:identity_url] }).find(:first) if session[:identity_url]
  end
end
