class UsersController < ApplicationController
  
  layout 'home'
  
  before_filter :user_is_admin, :only => [:index]
  before_filter :user_is_authenticated, :only => [:create, :new]
  before_filter :user_is_admin_or_authorized_for_action, :except => [:create, :new, :index]

  def new
    @user = flash[:new_user] || User.new
    @captcha = session[:captcha] || Captcha.new
  end
  
  def create
    params[:user][:identity_url] = session[:identity_url]
    @user = User.new( params[:user])
    # captcha may be valid before user is. in that case captcha parameters will not be present but
    # captcha in session will be present and valid
    @captcha = params[:captcha] ? Captcha.new( params[:captcha]) : session[:captcha]
    # make sure we run both sets of validations so user sees all errors at once
    @captcha.valid?
    @user.valid?
    if @captcha.valid? && @user.save
      flash[:new_user] = nil
      session[:captcha] = nil
      redirect_to @user
    else
      error  @user.errors.full_messages + @captcha.errors.full_messages
      flash[:new_user] = @user
      session[:captcha] = @captcha
      redirect_to new_user_url
    end
  end

  def edit
    @user = User.find( params[:id])
  end
  
  def update
    @user = User.find( params[:id])
    @user.attributes = params[:user]
    if @user.save
      inform "settings saved"
      redirect_to @user
    else
      error @user.errors.full_messages
      redirect_to edit_users_url( @user)
    end
  end

  def show
    @user = User.find( params[:id])
  end
  
  protected
  def page_title
    @page_title = "Your Account"
  end
  
  def user_action_on_resource_authorized
    registered_user.id == params[:id].to_i
  end
end