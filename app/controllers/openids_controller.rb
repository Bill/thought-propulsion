class OpenidsController < ApplicationController

  layout 'home'
  
  include ApplicationHelper # to get company_name method
  
  def new
    # TODO: show a form requesting the user's OpenID
  end

  def create
    authenticate_with_open_id_url params[:openid_url]
  end
  
  def finish_registration
    @user = User.find_by_identity_url( session[:identity_url])
  end

  #log a user out of the system
  def logout
      reset_session
      redirect_to home_url
  end
  
  def openid_authentication_callback
    return_to = url_for(:only_path => false,
                        :action => 'openid_authentication_callback')
    parameters = params.reject{|k,v| request.path_parameters[k] }
    openid_response = openid_consumer.complete( parameters, return_to)
    
    case openid_response.status
    when OpenID::Consumer::SUCCESS
      @user = User.find_by_identity_url( openid_response.endpoint.claimed_id)
      if @user.nil?
        after_successful_authentication_of_unregistered_principal( openid_response)
      else
        after_successful_authentication( @user)
      end
    when OpenID::Consumer::FAILURE
      after_unsuccessful_authentication( "Verification of #{ openid_response.endpoint.nil? || openid_response.endpoint.claimed_id.blank? ? 'OpenID' : openid_response.endpoint.claimed_id} failed: #{openid_response.message}")
    when OpenID::Consumer::CANCEL
      after_unsuccessful_authentication( 'OpenID verification cancelled by user.')
    else
      after_unsuccessful_authentication( 'Unknown response from OpenID server.')
    end
  end
  
  def openid_registration_callback
    _authenticate_with_open_id_url( params[:openid_identifier])
  end
  
  protected

    def openid_consumer
      @openid_consumer ||= OpenID::Consumer.new(session,      
        OpenIdAuthentication::DbStore.new())
    end
    
    def authenticate_with_open_id_url( open_id_url)
      begin
        
        begin
          response = openid_consumer.begin(open_id_url)
          
          sreg_request = OpenID::SReg::Request.new
          sreg_request.request_fields(['nickname', 'fullname', 'email', 'postcode', 'country'], false) # optional
          response.add_extension(sreg_request)
  
          return_to = url_for(:action=> 'openid_authentication_callback')
          trust_root = url_for(:controller=>'openids')
          redirect_url = response.redirect_url(trust_root, return_to)
          redirect_to( redirect_url)
          return
          
        rescue OpenID::OpenIDError
          # our flash rendering (application.rhtml) escapes values so we don't have to worry about escaping this URL
          flash[:error] = "Could not find OpenID server for #{open_id_url}: #{$!}"
        end

      rescue Timeout::Error
        # this happens when the user enters an OpenID (URL) that is has no OpenID metadata, or the server spec'd in meta-data is down
        flash[:error] = "Could not find OpenID server for #{open_id_url} - did you type that correctly?"
      end

      # we reach this line only if OpenID::DiscoveryFailure was thrown (or if HTTP method was not POST)
      redirect_to home_url
    end
    
    def after_successful_authentication( member)
      associate_authenticated_identity_with_session(member.identity_url)
      return_to_or_redirect( url_for(:controller => 'home', :action => 'index', :only_path => false))
    end
    
    # OpenID authentication succeeded but this principal is not yet registered with Lumeno.us... help her sign up
    def after_successful_authentication_of_unregistered_principal( response)
      flash[:info] = "Your identity has been verified but you're not yet a #{company_name} member&mdash;please register"
      registration_info = response.extension_response('http://openid.net/extensions/sreg/1.1', true)
      first_name = last_name = ''
      if registration_info.has_key?('fullname')
        parts = registration_info['fullname'].split
        first_name = parts[0]
        last_name = parts[1] unless parts.size < 2
      end
      @user = User.new(:identity_url => response.endpoint.claimed_id, :email => registration_info['email'], :first_name => first_name, :last_name => last_name, :zip => registration_info['postcode'], :country => registration_info['country'], :nickname =>  registration_info['nickname'])
      associate_authenticated_identity_with_session( @user.identity_url)
      render :action => 'finish_registration'
    end
    
    def after_unsuccessful_authentication( message)
      reset_session
      flash.now[:error] = message
      render(:action => 'new')
    end
    
    def associate_authenticated_identity_with_session(identity_url)
        session[:identity_url] = identity_url
    end
    
end