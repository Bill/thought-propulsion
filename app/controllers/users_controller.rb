class UsersController < ApplicationController
  
  layout 'home'
  
  before_filter :authenticated, :only => [:create]
  before_filter :registered, :except => [:create]
  
  def create
    params[:user][:identity_url] = session[:identity_url]
    @user = User.new( params[:user])
    begin
      @user.save!
      render :action => 'show'
    rescue ActiveRecord::RecordInvalid
      flash.now[:error] = @user.errors.full_messages
      render :action => 'new'
    end
  end
  
  protected
  def page_title
    @page_title = "Your Account"
  end
  
end