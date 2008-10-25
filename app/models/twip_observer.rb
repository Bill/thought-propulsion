class TwipObserver < ActiveRecord::Observer
  def before_validation( twip )
    # scan content for ImagePlacements
    # twip.body is not necessarily a well-formed XML document since it may have multiple roots.
    # put those under a root so libxml will be happy
    content = "<root>#{twip.body}</root>".to_libxml_doc.root
    image_placements = (content/'//@href').map do | href |
      id = href.inner_xml[ /\/image_placements\/(\d+)/, 1]
      ImagePlacement.find( id) unless id.nil?
    end.compact
    twip.image_placements = image_placements
    # If we simply assign the image_placments en masse then the reverse-pointer to the twip
    # will not be set in time for it to be available in ImagePlacement validations so we
    # set each pointer explicitly
    image_placements.each do |ip|
      ip.twip = twip
    end
  end
end