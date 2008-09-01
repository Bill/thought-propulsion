class TwipsController < TwiplApplicationController
  
  # no filter on index (filtering that action is all about access control on a per-record basis)
  before_filter :filter_user_is_registered, :only => [:create, :new]
  before_filter :filter_user_is_admin_or_authorized_for_action, :except => [:create, :new, :index]
  
  def index
    publisher = User.for_host( request.host).find(:first)
    (render( :file => "#{RAILS_ROOT}/public/404.html", :status => 404) and return) unless publisher
    @twips = authorized_twip_summary_for_publisher_and_viewer( publisher)
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
      wants.atomsvc { render :action => 'service_document', :layout => false}
    end
  end
  
  protected
  
  def page_title
    super + ' | Twip'
  end
  
  def user_action_on_resource_authorized
    Twip.find( params[:id]).owner == registered_user
  end
  
  def authorized_twip_summary_for_publisher_and_viewer( publisher)
    WillPaginate::Collection.create(params[:page] || 1, 3) do |pager|
      viewer = authenticated_identity_url
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