class TwipsController < ApplicationController
  
  layout 'home'
  
  before_filter :user_is_admin, :only => [:index]
  before_filter :user_is_registered, :only => [:create, :new]
  before_filter :user_is_admin_or_authorized_for_action, :except => [:create, :new, :index]

  def index
    @twips = registered_user.twips.paginate( :page => params[:page], :order => 'created_at DESC', :per_page => 3)
    respond_to do |wants|
      wants.atom { render :action => 'index', :layout => false}
      wants.html
    end    
  end
  
  def show
    @twip = Twip.find( params[:id])
    respond_to do |wants|
      wants.atom { render :action => 'show', :layout => false}
      wants.html
    end    
  end
  
  def new
    @twip = flash[:new_twip] || Twip.new
  end
  
  def create
    @twip = Twip.new( params[:twip])
    @twip.owner = registered_user
    if @twip.save
      inform "new twip created"
      flash[:new_twip] = nil
      redirect_to @twip
    else
      error  @twip.errors.full_messages
      flash[:new_twip] = @twip
      redirect_to new_twips_url
    end
  end
  
  def edit
    @twip = Twip.find( params[:id])
    respond_to do |wants|
      wants.html
    end    
  end
  
  def update
    @twip = Twip.find( params[:id])
    @twip.attributes = params[:twip]
    if @twip.save
      inform "twip changes saved"
      redirect_to @twip
    else
      error @twip.errors.full_messages
      redirect_to edit_twips_url( @twip)
    end
  end
  
  def service_document
    respond_to do |wants|
      wants.atomserv { render :action => 'service_document', :layout => false}
    end
  end
  
  protected
  
  def user_action_on_resource_authorized
    Twip.find( params[:id]).owner == registered_user
  end
end