# Note: we can't test ApplicationController directly so this is where we'll do it…

require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController, 'should inherit ApplicationController functionality' do

  integrate_views

  fixtures :users

  describe 'like routing' do
    
    describe 'by rejecting bad routes' do
      it 'like unknown subdomains of the Thought Propulsion corporate domain' do
        recognize_path( '', :method => :get, :host => 'foo.thoughtpropulsion.com').should == nil
      end
      it 'like Twipl-specific resources accessed on the Thought Propulsion corporate domain' do
        recognize_path( '/twips', :method => :get, :host => 'thoughtpropulsion.com').should == nil
      end
      it 'like Thought Propulsion corporate domain-specific routes accessed on Twipl' do
        recognize_path( '/why', :method => :get, :host => 'twipl.com').should == nil
      end
    end # bad routes

    describe 'by handling good routes' do
      
      # # Guess what: shared examples don't work so well in the context of the each/do blocks below
      # # so instead I had to find another way
      shared_examples_for 'login and logout' do
        it "route to login" do
          recognize_path( '/login', :method => :get, :host => @domain).should_not == nil
        end
        it "route to logout" do
          recognize_path( '/logout', :method => :get, :host => @domain).should_not == nil
        end
      end
      
      shared_examples_for 'profile management' do
        it "route to profile" do
          recognize_path( '/profile', :method => :get, :host => @domain).should_not == nil
        end
      end

      describe "for Thought Propulsion corporate site: thoughtpropulsion.com" do
        before(:each) do
          @domain = 'thoughtpropulsion.com'
        end
        
        it_should_behave_like 'login and logout'
        it_should_behave_like 'profile management'

        it "should route to root" do
          recognize_path( '', :method => :get, :host => @domain).should_not == nil
        end
        it "should route to Why page" do
          recognize_path( '/why', :method => :get, :host => @domain).should_not == nil
        end
        it "should route to the Twipl-Powered Thought Propulsion Blog" do
          # override Site host
          recognize_path( '', :method => :get, :host => "blog.#{@domain}").should_not == nil
        end
      end

      describe "on twipl.com" do
        before(:each) do
          @domain = 'twipl.com'
        end
        it_should_behave_like 'login and logout'
        it_should_behave_like 'profile management'

        it "for Twipl product site" do
          recognize_path( '', :method => :get, :host => @domain).should_not == nil
        end

        describe "for readers of sally's Twips on her Twipl-Powered site" do
          before(:each) do
            @domain = 'sally.twipl.com'
          end
          it "like sally's public Twip summary on the root of her domain" do
            # override Site host
            recognize_path( '', :method => :get, :host => @domain).should_not == nil
          end
        end
      end

      ## TODO: rspec-rails goes under the covers of route recognition and skips extract_request_environment
      ## as a result, our custom routing conditions like :published_as_alternate_twipl_domain aren't available
      ## and so this spec never succeeds
      # describe "on third-party domain: blog.sally.me" do
      #   before(:each) do
      #     @domain = 'blog.sally.me'
      #   end
      #   it_should_behave_like 'login and logout'
      #   it_should_behave_like 'profile management'
      # 
      #   it "like public Twip summary on root" do
      #     recognize_path( '', :method => :get, :host => @domain).should_not == nil
      #   end
      # end
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