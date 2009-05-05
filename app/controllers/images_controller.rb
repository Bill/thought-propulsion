class ImagesController < ApplicationController
  
  include ImagesHelper # image_src_url
  
  layout proc{ |controller| controller.params[:layout]}

  before_filter :filter_user_is_registered, :only => [:create, :create_json, :new]
  before_filter :filter_user_is_admin_or_authorized_for_action, :except => [:create, :create_json, :new, :show]
  # :show action performs its own access control
  
  def new
    @image = Image.new
  end

  # This is the entry point for YUI Editor to create an image (AJAX). It gets its own action
  # rather than just calling create, since YUI Editor sets the accept header to text/html
  # and expects text/html back, which would cause the create action to render HTML.
  def create_json
    respond_to do | wants |
      wants.json do
        _create do | image |
          if image.save
              render :layout => false, :json => { :status => 'UPLOADED', :image_url => url_for(:action=>'show', :id=>image.id)} 
              # returning application/json, text/x-json, text/json cause Firefox 3 to try to open an app
              # returning text/html or application/xhtml+xml causes ampersands (&) in json 
              # strings to get html_escape (&amp;)
              response.content_type = Mime::HTML
          else
            render :layout => false, :json => { :status => 'FAILED'}
            # otherwise Rails returns application/json and Firefox 3 tries to open an app
            response.content_type = Mime::HTML
          end
        end
      end
    end
  end

  def create
    _create do | image |
      if image.save
        respond_to do | wants |
          wants.json do
            render :layout => false, :json => { :status => 'UPLOADED', :image_url => url_for(:action=>'show', :id=>image.id)} 
          end
          wants.html do
            inform "image #{image.id} saved"
            redirect_to :action => 'show', :id => image.id
          end
        end
      else
        respond_to do | wants |
          wants.json{ render :layout => false, :json => { :status => 'FAILED'} }
          wants.html do
            error "failed to save image"
            render :action => 'new'
          end
        end
      end
    end
  end
  
  def show
    viewer = authenticated_identity_url
    @image = Image.access_public_or_shared_with( viewer).find( params[:id])
    redirect_to image_src_url( @image ) unless @image.nil?
  end
  
  protected
  def user_action_on_resource_authorized
    Image.find( params[:id]).author == registered_user
  end
  
  def _create
    # TODO: use attr_protected :owner once it doesn't clash with attachment-fu
    #   <RuntimeError: Declare either attr_protected or attr_accessible for Image, but not both.>
    params[:image].delete(:owner)
    @image = Image.new( params[:image])
    @image.author = registered_user
    yield @image
  end
  
end