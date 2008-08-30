# Note: we can't test ApplicationController directly so this is where we'll do it…

require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, 'should inherit ApplicationController functionality' do

  integrate_views

  fixtures :users

  before(:each) do
    session[:identity_url] = 'fred.myopenid.com' # matches user in fixtures
    get 'index'
  end

  it 'should find User for session when session is missing URL scheme' do
    assigns[:registered_user].nil?.should == false
  end
end