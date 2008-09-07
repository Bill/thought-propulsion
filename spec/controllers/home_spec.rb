# Note: we can't test ApplicationController directly so this is where we'll do it…

require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, 'should inherit ApplicationController functionality' do

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
      # shared_examples_for 'login and logout'
      # shared_examples_for 'profile management'
      login_and_logout_examples = <<-EOS
      it "route to login on domain \#{domain}" do
        recognize_path( '/login', :method => :get).should_not == nil
      end
      it "route to logout on domain \#{domain}" do
        recognize_path( '/logout', :method => :get).should_not == nil
      end
      EOS

      profile_management_examples = <<-EOS
      it "route to profile on domain \#{domain}" do
        recognize_path( '/profile', :method => :get).should_not == nil
      end
      EOS
      
      for_subdomains( 'thoughtpropulsion.com') do | domain |
        describe "for Thought Propulsion corporate site on #{domain}" do
          eval login_and_logout_examples
          eval profile_management_examples
          
          it "should route to root on #{domain}" do
            recognize_path( '', :method => :get).should_not == nil
          end
          it "should route to Why page on #{domain}" do
            recognize_path( '/why', :method => :get).should_not == nil
          end
          it "should route to the Twipl-Powered Thought Propulsion Blog on #{domain}" do
            # override Site host
            recognize_path( '', :method => :get, :host => "blog.#{domain}").should_not == nil
          end
        end
      end

      for_subdomains( 'twipl.com' ) do | domain |
        describe "on twipl.com subdomains like #{domain}" do
          eval login_and_logout_examples
          eval profile_management_examples

          it "for Twipl product site on #{domain}" do
            recognize_path( '', :method => :get).should_not == nil
          end

          ['sally','fred'].each do | nickname |
            describe "for readers of #{nickname}'s Twips on Twipl-Powered site: #{domain} (under twipl.com)" do
              it "like #{nickname}'s public Twip summary on root of #{domain}" do
                # override Site host
                recognize_path( '', :method => :get, :host => "#{nickname}.#{domain}").should_not == nil
              end
            end
          end
          
        end
      end

      ['foo.net', 'bar.baz.au', 'meme-rocket.com', 'www.meme-rocket.com'].each do | domain |
        describe "on third-party domain #{domain}" do
          eval login_and_logout_examples
          eval profile_management_examples

          it "like public Twip summary on root of #{domain}" do
            recognize_path( '', :method => :get, :host => "#{domain}").should_not == nil
          end
        end
      end
    end
  end # good routes

  describe 'when principal is authenticated' do
    before(:each) do
      session[:identity_url] = 'fred.myopenid.com' # matches user in fixtures
    end

    for_subdomains( 'thoughtpropulsion.com') do | domain |
      it "should find User for session when session is missing URL scheme from #{domain}" do
        get 'index'
        assigns[:registered_user].nil?.should == false
      end
    end
  end

end