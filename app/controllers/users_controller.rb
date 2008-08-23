class UsersController < ApplicationController
  
  layout 'home'
  
  before_filter :authenticated, :only => [:create]
  before_filter :registered, :except => [:create]

  def new
    @user = flash[:new_user] || User.new
  end
  
  def show
    @user = User.find( params[:id])
  end
  
  def create
    params[:user][:identity_url] = session[:identity_url]
    @user = User.new( params[:user])
    begin
      @user.save!
      redirect_to @user
    rescue ActiveRecord::RecordInvalid
      error @user.errors.full_messages
      flash[:new_user] = @user
      redirect_to new_user_url
    end
  end
  
  protected
  def page_title
    @page_title = "Your Account"
  end
  
end