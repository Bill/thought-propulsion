require File.dirname(__FILE__) + '/../spec_helper'

describe OpenidsController do
  integrate_views

  fixtures :users
  
  before(:each) do
    mock_valid_authentication
    post 'openid_authentication_callback'
  end

  describe 'receiving valid authentication for unregistered principal' do
    
    it 'should be an unregistered principal' do
      User.with_same_identity( user).count.should == 0
    end

    it 'should set identity_url in session' do
      session[:identity_url].should == identity_url
    end

    it 'should set User in flash' do
      flash[:new_user].should_not == nil
    end

    it 'should set User.identity_url in flash' do
      flash[:new_user].identity_url.should == identity_url
    end

    it 'should redirect to new registration form' do
      response.should be_redirect
      # # TODO: fixme
      # response.should redirect_to( :controller => 'users', :action => 'new')
    end
    
    it 'should not be logged in' do
      assigns[:registered_user].nil?.should == true
    end

    def identity_url
      'http://not-fred.myopenid.com' # does NOT match a user in fixtures
    end
  end
  
  describe 'receiving valid authentication for registered principal' do
        
    it 'should be a registered principal' do
      User.with_same_identity( user).count.should == 1
    end
    
    it 'should skip registration form' do
      response.should be_redirect
      # TODO: fixme
      # response.should redirect_to( url_for( '/'))
      # assert_redirected_to url_for( '/')
    end
    
    # Seems like this condition is backward but it isn't. In this case, the authenticated
    # principals OpenID is set in the session (session[:identity_url]) but it is not until 
    # that user returns (via another action) that the @registered_user will be set
    it 'should be logged in' do
      assigns[:registered_user].nil?.should == true
    end
    
    def identity_url
      'http://fred.myopenid.com' # matches a user in fixtures
    end
  end
  
  def user
    User.new do |user|
      user.identity_url = identity_url
    end
  end
  
  def mock_valid_authentication
    openid_response = returning( mock( 'response' ) ) do |r|
      r.stubs(:status).returns(OpenID::Consumer::SUCCESS)
      r.stubs(:extension_response).returns( HashWithIndifferentAccess.new(:email => 'whatever'))
      endpoint = returning( mock( 'endpoint' ) ) do |e|
        e.stubs(:claimed_id).returns( identity_url)
      end
      r.stubs(:endpoint).returns(endpoint)
    end
    OpenID::Consumer.any_instance.stubs(:complete).returns(openid_response)
  end
  
end