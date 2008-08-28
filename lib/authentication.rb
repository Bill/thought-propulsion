module Authentication
  
  # The next three methods represent three increasing levels of authentication (they build on one another).
  # first, is the user authenticated? more properly, the principal is authenticated because there may be
  # no User object for her yet
  def filter_user_is_authenticated
    unless( user_is_authenticated)
      redirect_to_login
    end
  end
  
  def user_is_authenticated
    result = false
    respond_to do |wants|
      wants.atom { result = http_basic_authentication}
      wants.atomsvc { result = http_basic_authentication}
      wants.html do
        result = ! session[:identity_url].nil?
      end
    end
    result
  end
  
  def redirect_to_login( msg = 'Please log in')
    respond_to do |wants|
      wants.atom { head 403}
      wants.atomsvc { head 403}
      wants.html do
        session[:return_to] = (request.ssl? ? 'https' : 'http') + "://#{request.host}#{request.port.blank? ? '' : ':' + request.port.to_s}" + request.request_uri
        # seems like this out to be :after_redirect but doing so causes it to not display!
        error msg #, :after_redirect
        redirect_to home_url
      end
    end
  end
  
  protected
  
  def http_basic_authentication
    result = false
    authenticate_or_request_with_http_basic do |username, password|
      # we're using the User's id as the 'username' and the User's authenticator as the password
      result = (u = User.find(username)) && u.authenticator == password
    end
    result
  end
end