require File.dirname(__FILE__) + '/../spec_helper'

describe OpenidsController, 'receiving valid authentication for unregistered principal' do
  
  integrate_views
  
  fixtures :users

  before(:each) do
    mock_valid_authentication
  end
  
  it 'should render new form' do
    post 'openid_authentication_callback'
    response.should redirect_to( new_user_path)
  end
  
  def mock_valid_authentication
    openid_response = mock_builder( 'response' ) do |r|
      r.stubs(:status).returns(OpenID::Consumer::SUCCESS)
      r.stubs(:extension_response).returns( HashWithIndifferentAccess.new(:email => 'whatever'))
      endpoint = mock_builder( 'endpoint') do |e|
        e.stubs(:claimed_id).returns('fred')        
      end
      r.stubs(:endpoint).returns(endpoint)
    end
    OpenID::Consumer.any_instance.stubs(:complete).returns(openid_response)
  end
end