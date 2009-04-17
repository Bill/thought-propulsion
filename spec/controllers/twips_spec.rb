require File.dirname(__FILE__) + '/../spec_helper'

describe TwipsController do

  integrate_views

  fixtures :users, :twips

  shared_examples_for 'show Twip' do
    it 'should be OK' do
      response.response_code.should == 200
    end
    it 'should show Twip' do
      response.should include_text( twip.body)
    end
  end

  shared_examples_for 'hide Twip' do
    it 'should be 404' do
      response.response_code.should == 404
    end
    it 'should hide Twip' do
      response.should_not include_text( twip.body)
    end
  end

  describe 'when providing HTML content' do

    before(:each) do
      request.env['HTTP_ACCEPT'] = 'text/html'
      rescue_action_in_public! # tell Rails to turn exceptions into HTTP status codes
    end

    describe 'to a registered principal' do

      before(:each) do
        stub_valid_authentication_for_registered_principal
      end

      describe 'when script tag is posted' do
        before(:each) do
          @original_twip_count = Twip.count
          content = "<script src='foo.bar.com/baz' type='text/javascript'></script><p>hellow world</p>"
          post 'create', :twip => {:title => 'important!', :body => content, :public => true}
        end

        it 'should redirect' do
          response.should be_redirect
        end
        
        it 'should create a new Twip' do
          Twip.count.should == @original_twip_count + 1
        end
      end
      
      describe 'when principal shows a Twip' do

        before(:each) do
          get 'show', :id => twip.id
        end
        
        describe 'authored by herself and marked private' do
          def twip; twips(:fred_private_twip); end
          it_should_behave_like 'show Twip'
        end

        describe 'authored by herself and marked public' do
          def twip; twips(:fred_public_twip); end
          it_should_behave_like 'show Twip'
        end
      
        describe "authored by another and marked public" do
          def twip; twips(:sally_public_twip); end
          it_should_behave_like 'show Twip'
        end
      
        describe "authored by another and marked private" do
          def twip; twips(:sally_private_twip); end
          it_should_behave_like 'hide Twip'
        end
      end
      
      def stub_valid_authentication_for_registered_principal
        session[:identity_url] = users(:fred).identity_url # matches user in fixtures
      end

    end # 'to a registered principal'
    
    describe 'to an unauthenticated principal' do
      
      describe 'when principal shows a Twip' do

        before(:each) do
          get 'show', :id => twip.id
        end
        
        describe "authored by another and marked public" do
          def twip; twips(:sally_public_twip); end
          it_should_behave_like 'show Twip'
        end
      
        describe "authored by another and marked private" do
          def twip; twips(:sally_private_twip); end
          it_should_behave_like 'hide Twip'
        end
      end

      def stub_no_authentication
        session[:identity_url] = nil
      end
    end
  end # 'when providing HTML content'
end # TwipsController