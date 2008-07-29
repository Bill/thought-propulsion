# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  before_filter :load_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '75d37e2b85a64152386bd5be91124174'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  protected
  
  # We sometimes interrupt the user's flow to require a login (or registration). Rather than blindly
  # redirecting to e.g. home after that, if the user was going somewhere to start with, then redirect her
  # there
  def return_to_or_redirect( default_destination)
    redirect_to session[:return_to] || default_destination
    session[:return_to] = nil # I know no other way to "clear" a slot in the session!
  end
  
  private

  def load_user
    @user = User.find_by_identity_url( session[:identity_url]) if session[:identity_url]
  end

  def authenticated
    if session[:identity_url].nil?
      session[:return_to] = (request.ssl? ? 'https' : 'http') + "://#{request.host}#{request.port.blank? ? '' : ':' + request.port.to_s}" + request.request_uri
      flash[:error] = "Please log in"
      redirect_to home_url
      false
    else
      true
    end
  end
  
  def registered
    authenticated && ! @user.blank?
  end
end
