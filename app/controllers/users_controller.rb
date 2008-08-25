class UsersController < ApplicationController
  
  layout 'home'
  
  before_filter :authenticated, :only => [:create]
  before_filter :registered, :except => [:create]

  def new
    @user = flash[:new_user] || User.new
    @captcha = session[:captcha] || Captcha.new
  end
  
  def show
    @user = User.find( params[:id])
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
  
  protected
  def page_title
    @page_title = "Your Account"
  end
  
end