class UsersController < ApplicationController
  
  layout 'home'
  
  before_filter :authenticated
  
  def create
    params[:user][:identity_url] = session[:identity_url]
    @user = User.new( params[:user])
    begin
      @user.save!
      render :action => 'show'
    rescue ActiveRecord::RecordInvalid
      flash[:error] = @user.errors.full_messages
      render :action => 'new'
    end
  end

  private
  def authenticated
    if session[:identity_url].nil?
      flash[:error] = "Please log in"
      redirect_to :controller => 'openids', :action => 'new'
      false
    else
      true
    end
  end
end