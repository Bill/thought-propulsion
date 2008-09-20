class TwipsController < ApplicationController
  
  # layout proc{ |controller| controller.params[:layout]}
  layout proc{ | controller | controller.layout }
  
  # no filter on index (filtering that action is all about access control on a per-record basis)
  before_filter :filter_user_is_registered, :only => [:create, :new]
  before_filter :filter_user_is_admin_or_authorized_for_action, :except => [:create, :new, :index, :show]
  
  before_filter :include_scripts
  
  def index
    publisher = User.for_host( request.host).find(:first)
    (render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404) and return) unless publisher
    @twips = authorized_twip_summary_for_publisher_and_viewer( publisher, authenticated_identity_url)
    respond_to do |wants|
      wants.atom { render :action => 'index', :layout => false}
      wants.html
    end    
  end
  
  def show
    viewer = authenticated_identity_url
    @twip = Twip.access_public_or_shared_with( viewer).find( params[:id])
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
    @twip.author = registered_user
    if @twip.save
      inform "new twip created"
      flash[:new_twip] = nil
      redirect_to url_for( :controller => 'twips', :action => 'show', :id => @twip.id)
    else
      error  @twip.errors.full_messages
      flash[:new_twip] = @twip
      redirect_to url_for( :controller => 'twips', :action => 'new')
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
      redirect_to url_for( :controller => 'twips', :action => 'show', :id => @twip.id)
    else
      error @twip.errors.full_messages
      redirect_to url_for( :controller => 'twips', :action => 'edit', :id => @twip.id)
    end
  end
  
  def service_document
    respond_to do |wants|
      wants.atomsvc { render :action => 'service_document', :layout => false}
    end
  end
  
  protected
  
  def include_scripts
    include_tags = render_to_string( :partial => 'editor/head_elements_min' )
    # um, see e.g. layout.rb line 254 in Rails 2.1.0. content_for variables have the form @content_for_<name>
    @template.instance_variable_set("@content_for_head", include_tags )
  end

  def user_action_on_resource_authorized
    Twip.find( params[:id]).author == registered_user
  end
  
  def authorized_twip_summary_for_publisher_and_viewer( publisher, viewer)
    WillPaginate::Collection.create(params[:page] || 1, 3) do |pager|
      if( publisher)
        visible = publisher.twips.access_public_or_shared_with( viewer)
        this_page = visible.find(:all, :limit => pager.per_page, :offset => pager.offset, :order => 'created_at DESC')
        pager.replace( this_page )
      end
      unless pager.total_entries
        pager.total_entries = 0
      end
    end
  end

end