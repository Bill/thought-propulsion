class OpenidsController < ApplicationController

  include ApplicationHelper # to get company_name method
  
  def new
    # TODO: show a form requesting the user's OpenID
  end

  def create
    authenticate_with_open_id_url params[:openid_url]
  end
  
  #log a user out of the system
  def logout
      reset_session
      # FIXME: url helper
      redirect_to url_for( '/')
  end
  
  def openid_authentication_callback
    return_to = url_for(:only_path => false,
                        :action => 'openid_authentication_callback')
    parameters = params.reject{|k,v| request.path_parameters[k] }
    openid_response = openid_consumer.complete( parameters, return_to)
    
    case openid_response.status
    when OpenID::Consumer::SUCCESS
      after_successful_authentication( openid_response)
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
  
          return_to = url_for(:action => 'openid_authentication_callback')
          # This controller is in play for all the throughtpropulsion.com domains as well as the twipl.com ones
          # set the trust root to the current URL minus the path part
          trust_root = request.url.split(request.path)[0]
          redirect_url = response.redirect_url(trust_root, return_to)
          redirect_to( redirect_url)
          return
          
        rescue OpenID::OpenIDError
          # our flash rendering (application.rhtml) escapes values so we don't have to worry about escaping this URL
          error "Could not find OpenID server for #{open_id_url}: #{$!}"
        end

      rescue Timeout::Error
        # this happens when the user enters an OpenID (URL) that is has no OpenID metadata, or the server spec'd in meta-data is down
        error "Could not find OpenID server for #{open_id_url} - did you type that correctly?"
      end

      # we reach this line only if OpenID::DiscoveryFailure was thrown (or if HTTP method was not POST)
      redirect_to url_for( '/')
    end
    
    def after_successful_authentication( response)
      registration_info = response.extension_response('http://openid.net/extensions/sreg/1.1', true)
      first_name = last_name = ''
      if registration_info.has_key?('fullname')
        parts = registration_info['fullname'].split
        first_name = parts[0]
        last_name = parts[1] unless parts.size < 2
      end
      @user = User.new(:email => registration_info['email'], :first_name => first_name, :last_name => last_name, :zip => registration_info['postcode'], :country => registration_info['country'], :nickname =>  registration_info['nickname'])
      @user.identity_url = response.endpoint.claimed_id
      associate_authenticated_identity_with_session( @user.normalized_identity_url)
      if( User.with_same_identity( @user).count > 0)
        redirect_to_original_destination
      else
        flash[:new_user] = @user
        redirect_to :controller => 'users', :action => 'new'
      end
    end
    
    def after_unsuccessful_authentication( message)
      reset_session
      error message, :now
      render(:action => 'new')
    end
end