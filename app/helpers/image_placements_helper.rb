module ImagePlacementsHelper
  def image_placement_url( image_placement)
    url_for :controller => 'image_placements', :action => 'show', :id => image_placement.id
  end
end