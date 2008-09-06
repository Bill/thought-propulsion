class UsersController < ApplicationController

  layout proc{ |controller| controller.params[:layout]}
  
  before_filter :filter_user_is_admin, :only => [:index]
  before_filter :filter_user_is_authenticated, :only => [:new, :create]
  before_filter :filter_user_is_admin_or_authorized_for_action, :except => [:new, :create, :index]

  def new
    @user = flash[:new_user] || User.new
    @captcha = session[:captcha] || Captcha.new
  end
  
  def create
    @user = User.new( params[:user])
    @user.identity_url = session[:identity_url]
    @user.set_sensitive_parameters( params[:user], registered_user, authenticated_identity_url)
    # captcha may be valid before user is. in that case captcha parameters will not be present but
    # captcha in session will be present and valid
    @captcha = params[:captcha] ? Captcha.new( params[:captcha]) : session[:captcha]
    # make sure we run both sets of validations so user sees all errors at once
    @captcha.valid?
    @user.valid?
    if @captcha.valid? && @user.save
      flash[:new_user] = nil
      session[:captcha] = nil
      inform "welcome #{@user.nickname}"
      redirect_to @user
    else
      error  @user.errors.full_messages + @captcha.errors.full_messages
      session[:captcha] = @captcha
      render :action => 'new'
    end
  end

  def edit
    @user = User.find( params[:id])
  end
  
  def update
    @user = User.find( params[:id])
    @user.attributes = params[:user]
    @user.set_sensitive_parameters( params[:user], registered_user, authenticated_identity_url)
    if @user.save
      inform "settings saved"
      redirect_to @user
    else
      error @user.errors.full_messages
      render :action => 'edit'
    end
  end

  def show
    @user = User.find( params[:id])
  end

  def profile
    redirect_to registered_user
  end
  
  protected
  
  def page_title
    super + ' | Your Account'
  end
  
  def user_action_on_resource_authorized
    registered_user.id == params[:id].to_i
  end
  
end