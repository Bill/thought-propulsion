# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  ALERT_CATEGORIES = %w(error warn inform).collect{|c| c.to_sym}
  
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
  
  protected
  
  # We sometimes interrupt the user's flow to require a login (or registration). Rather than blindly
  # redirecting to e.g. home after that, if the user was going somewhere to start with, then redirect her
  # there
  def return_to_or_redirect( default_destination)
    redirect_to session[:return_to] || default_destination
    session[:return_to] = nil # I know no other way to "clear" a slot in the session!
  end
  
  def page_title
    @page_title = "iPhone &amp; Web Apps Built About You"
  end
  
  def error( msg, now_later = :later)
    alert( :error, msg, now_later)
  end
  def warn( msg, now_later = :later)
    alert( :warn, msg, now_later)
  end
  def inform( msg, now_later = :later)
    alert( :inform, msg, now_later)
  end

  def alert( category, msg, now_later = :later)
    raise ArgumentError("#{category.to_s} is not a valid alert category") unless ALERT_CATEGORIES.include?(category)
    (now_later == :later ? flash : flash.now)[category] = to_array( flash[category]).concat( to_array( msg))
  end
  
  
  private
  
  def to_array(obj)
    case obj
      when nil then []
      when Array then obj
      else [obj]
    end
  end

  def load_user
    @user = User.find_by_identity_url( session[:identity_url]) if session[:identity_url]
  end

  def authenticated
    if session[:identity_url].nil?
      session[:return_to] = (request.ssl? ? 'https' : 'http') + "://#{request.host}#{request.port.blank? ? '' : ':' + request.port.to_s}" + request.request_uri
      error "Please log in", :after_redirect
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
