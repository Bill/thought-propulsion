class ImagePlacementsController < ApplicationController

  include ImagesHelper

  before_filter :filter_user_is_registered, :only => [:create_json]
  before_filter :filter_user_is_admin_or_authorized_for_action, :except => [:create_json, :show]
  # :show action performs its own access control
  
  # This is the entry point for YUI Editor to create an image (AJAX). It gets its own action
  # rather than just calling create, since YUI Editor sets the accept header to text/html
  # and expects text/html back, which would cause the create action to render HTML.
  def create_json
    respond_to do | wants |
      wants.json do
        _create do | image, image_placement |
          if image.save && image_placement.save
              render :layout => false, :json => { :status => 'UPLOADED', :image_url => url_for(:action=>'show', :id=>image_placement.id, :only_path => true)} 
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
  
  # GET /image_placements/1
  def show
    @image_placement = ImagePlacement.find( params[:id])
    if @image_placement && @image_placement.access_public_or_shared_with?( authenticated_identity_url)
      redirect_to image_src_url( @image_placement.image )
    else
      render :nothing=>true, :status=>403
    end
  end
  
  protected
  def user_action_on_resource_authorized
    ImagePlacment.find( params[:id]).image.author == registered_user
  end
  
  def _create
    # TODO: use attr_protected :owner once it doesn't clash with attachment-fu
    #   <RuntimeError: Declare either attr_protected or attr_accessible for Image, but not both.>
    params[:image].delete(:owner)
    @image = Image.new( params[:image])
    @image.author = registered_user
    @image_placement = ImagePlacement.new
    @image_placement.image = @image
    yield @image, @image_placement
  end
  
end
