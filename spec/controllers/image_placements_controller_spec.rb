require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImagePlacementsController do

  integrate_views
  
  fixtures :users, :twips, :images, :image_placements

  describe 'to an unauthenticated principal' do
  
    it "it should show Image for public Twip" do
      get :show, :id => image_placements(:for_fred_public_twip).id
      response.should be_redirect
    end

    it "it should hide Image for private Twip" do
      get :show, :id => image_placements(:for_fred_private_twip).id
      response.response_code.should == 403
    end
  end
  
  describe 'to an authenticated principal' do
    def stub_valid_authentication_for_registered_principal
      session[:identity_url] = users(:fred).identity_url # matches user in fixtures
    end
  
    before(:each) do
      stub_valid_authentication_for_registered_principal
    end
  
    it "it should show Image for my public Twip" do
      get :show, :id => image_placements(:for_fred_public_twip).id
      response.should be_redirect
    end

    it "it should show Image for private Twip" do
      get :show, :id => image_placements(:for_fred_private_twip).id
      response.should be_redirect
    end
  end
  
end
