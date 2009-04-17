# Note: we can't test ApplicationController directly so this is where we'll do it…

require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController, 'should inherit ApplicationController functionality' do

  integrate_views

  fixtures :users

  describe 'like routing' do
    
    describe 'by rejecting bad routes' do
      it 'like unknown subdomains of the Thought Propulsion corporate domain' do
        params_from( :get, '', :host => 'foo.thoughtpropulsion.com').should.blank?
      end
      it 'like Twipl-specific resources accessed on the Thought Propulsion corporate domain' do
        params_from( :get, '/twips', :host => 'www.thoughtpropulsion.com').should.blank?
      end
      it 'like Thought Propulsion corporate domain-specific routes accessed on Twipl' do
        params_from( :get, '/why', :host => 'www.twipl.com').should.blank?
      end
    end # bad routes

    describe 'by handling good routes' do
      
      # # Guess what: shared examples don't work so well in the context of the each/do blocks below
      # # so instead I had to find another way
      shared_examples_for 'login and logout' do
        it "route to login" do
          params_from( :get, '/login', :host => @domain).should_not == nil
        end
        it "route to logout" do
          params_from( :get, '/logout', :host => @domain).should_not == nil
        end
      end
      
      shared_examples_for 'profile management' do
        it "route to profile" do
          params_from( :get, '/profile', :host => @domain).should_not == nil
        end
      end

      describe "for Thought Propulsion corporate site: thoughtpropulsion.com" do
        before(:each) do
          @domain = 'www.thoughtpropulsion.com'
        end
        
        it "should route to root" do
          params_from( :get, '', :host => @domain).should_not == nil
        end
        it "should route to Why page" do
          params_from( :get, '/why', :host => @domain).should_not == nil
        end
        it "should route to the Twipl-Powered Thought Propulsion Blog" do
          # override Site host
          params_from( :get, '', :host => "blog.thoughtpropulsion.com").should_not == nil
        end
      end

      describe "on twipl.com" do
        before(:each) do
          @domain = 'www.twipl.com'
        end
        it_should_behave_like 'login and logout'
        it_should_behave_like 'profile management'

        it "for Twipl product site" do
          params_from( :get, '', :host => @domain).should_not == nil
        end

        describe "for readers of sally's Twips on her Twipl-Powered site" do
          before(:each) do
            @domain = 'sally.twipl.com'
          end
          it "like sally's public Twip summary on the root of her domain" do
            # override Site host
            params_from( :get, '', :host => @domain).should_not == nil
          end
        end
      end

      describe "on third-party domain: blog.sally.me" do
        before(:each) do
          @domain = 'blog.sally.me'
        end
        it_should_behave_like 'login and logout'
        it_should_behave_like 'profile management'
      
        it "like public Twip summary on root" do
          params_from( :get, '', :host => @domain).should_not == nil
        end
      end
    end
  end # good routes

  describe 'when principal is authenticated' do
    before(:each) do
      session[:identity_url] = 'fred.myopenid.com' # matches user in fixtures
    end

    it "should find User for session when session is missing URL scheme" do
      get 'index'
      assigns[:registered_user].nil?.should == false
    end
  end

end