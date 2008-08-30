require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, '' do

  integrate_views

  fixtures :users
  
  before(:each) do
    request.env['HTTP_ACCEPT'] = 'text/html'
  end
  
  describe 'unauthenticated principal' do

    describe 'accessing actions that require authentication only' do

      after(:each) do
        response.response_code.should == 302
      end
  
      it 'should not see new User form' do
        get 'new'
      end

      it 'should not be able to post to User create form' do
        post 'create'
      end
    end
    
    describe 'accessing actions that require authentication and registration' do

      after(:each) do
        response.response_code.should == 403
      end

      it 'should not be able to see User show form' do
        get 'show/1'
      end

      it 'should not be able to see User edit form' do
        get '/1/edit'
      end

      it 'should not be able to post to User update form' do
        post 'update/1'
      end
    end
  end # 'unauthenticated principal'

  describe 'authenticated principal' do

    before(:each) do
      mock_valid_authentication
    end

    it 'should start with a new User object' do
      get 'new'
      assigns[:user].nil?.should == false
    end

    describe 'presenting valid captcha' do

      before(:each) do
        # mock_valid_captcha
        @captcha = Captcha.new(:captcha => 'CAPTCHA', :captcha_verified=>false)
      end

      describe 'with all required fields present' do
        before(:each) do
          @user = User.new(:email => 'email', :first_name => 'not-fred', :last_name => 'jones', :zip => 34567, :country => 'mexico', :nickname => 'not-freddo')
          post 'create', {:user => @user.attributes, :captcha => @captcha.attributes}
        end

        it 'should save User' do
          assigns[:user].should_not be_new_record
        end
      end
    
      describe 'with missing nickname' do
        before(:each) do
          @user = User.new(:email => 'email', :first_name => 'not-fred', :last_name => 'jones', :zip => 34567, :country => 'mexico')
          post 'create', {:user => @user.attributes, :captcha => @captcha.attributes}
        end

        it 'should redisplay new form' do
          response.should render_template('new')
        end

        it 'should fail save' do
          assigns[:user].should be_new_record
        end
        
        it 'should succeed on save after all required fields are presented' do
          @user.nickname = 'not-freddo'
          post 'create', {:user => @user.attributes}
          assigns[:user].should_not be_new_record
        end
      end

      def mock_valid_captcha
        session[:captcha] = mock('captcha', :valid? => true, :errors => mock('captcha errors', :full_messages => []), :captcha_verified => true)
      end
    end # 'presenting valid captcha'
  
    describe 'presenting invalid captcha' do

      before(:each) do
        mock_invalid_captcha
      end

      describe 'with all required fields present' do
        before(:each) do
          @user = User.new(:email => 'email', :first_name => 'not-fred', :last_name => 'jones', :zip => 34567, :country => 'mexico', :nickname => 'not-freddo')
          post 'create', {:user => @user.attributes}
        end

        it 'should not save User' do
          assigns[:user].should be_new_record
        end
      end
    
      describe 'with missing nickname' do
        before(:each) do
          @user = User.new(:email => 'email', :first_name => 'not-fred', :last_name => 'jones', :zip => 34567, :country => 'mexico')
          post 'create', {:user => @user.attributes}
        end

        it 'should redisplay new form' do
          response.should render_template('new')
        end

        it 'should fail save' do
          assigns[:user].should be_new_record
        end
      end

      def mock_invalid_captcha
        session[:captcha] = mock('captcha', :valid? => false, :errors => mock('captcha errors', :full_messages => ['bad'], :on => ['bad']), :captcha_verified => false, :captcha => 'test', :captcha_session=>'1')
      end
    end

    describe 'registered user' do
      describe 'when looking for her own profile' do
        it 'should see show form' do
          get 'show', :id => users(:fred).id
          response.should be_success
        end
        it 'should see edit form' do
          get 'edit', :id => users(:fred).id
          response.should be_success
        end
        it 'should be able to update attributes' do
          post 'update', {:id => users(:fred).id, :nickname => 'freddo'}
          response.should redirect_to( user_path(users(:fred)))
        end
      end
      describe "when looking for someone else's profile" do
        it 'should not see show form' do
          get 'show', :id => users(:sally).id
          response.should_not be_success
        end
        it 'should not see edit form' do
          get 'edit', :id => users(:sally).id
          response.should_not be_success
        end
        it 'should not be able to edit attributes' do
          post 'update', :id => users(:sally).id, :nickname => 'freddo'
          response.headers["Status"].should == "403 Forbidden"
        end
      end
      
      def mock_valid_authentication
        session[:identity_url] = users(:fred).identity_url # matches user in fixtures
      end
      
    end # 'registered user'

    describe 'administrator' do
    end # 'administrator'

    def mock_valid_authentication
      session[:identity_url] = 'not-fred.myopenid.com' # does NOT match user in fixtures
    end

  end # 'authenticated principal

end # UsersController top-level context ''