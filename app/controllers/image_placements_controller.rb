class ImagePlacementsController < ApplicationController

  include ImagesHelper
  
  # GET /image_placements/1
  def show
    @image_placement = ImagePlacement.find( params[:id])
    if @image_placement && @image_placement.twip.access_public_or_shared_with?( authenticated_identity_url)
      redirect_to image_src_url( @image_placement.image )
    else
      render :nothing=>true, :status=>403
    end
  end
end
