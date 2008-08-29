require File.dirname(__FILE__) + '/../spec_helper'

describe OpenidsController, 'receiving valid authentication for unregistered principal' do
  
  integrate_views
  
  fixtures :users

  before(:each) do
    mock_valid_authentication
  end
  
  it 'should set identity_url' do
    post 'openid_authentication_callback'
    assigns[:user].identity_url.should == 'fred'
  end

  it 'should redirect to new User form' do
    post 'openid_authentication_callback'
    response.should redirect_to( new_user_path)
  end

  it 'should set User in flash' do
    post 'openid_authentication_callback'
    flash[:new_user].should_not == nil
  end

  it 'should set User.identity_url in flash' do
    post 'openid_authentication_callback'
    flash[:new_user].identity_url.should == 'fred'
  end
  
  def mock_valid_authentication
    openid_response = returning( mock( 'response' ) ) do |r|
      r.stubs(:status).returns(OpenID::Consumer::SUCCESS)
      r.stubs(:extension_response).returns( HashWithIndifferentAccess.new(:email => 'whatever'))
      endpoint = returning( mock( 'endpoint' ) ) do |e|
        e.stubs(:claimed_id).returns('fred')        
      end
      r.stubs(:endpoint).returns(endpoint)
    end
    OpenID::Consumer.any_instance.stubs(:complete).returns(openid_response)
  end
end