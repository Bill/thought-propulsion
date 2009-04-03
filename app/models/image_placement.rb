class ImagePlacement < ActiveRecord::Base
  belongs_to :twip
  belongs_to :image
  
  # just validating the presence of the id--not actually going out to the db and looking for the record
  validates_presence_of :image
  
  def validate
    # When creating a new Twip we create ImagePlacements in advance. That means that ImagePlacements
    # must be valid for twip.nil?
    # When we do finally save the Twip we will associate its ImagePlacements. At that point we must
    # verify that the Twip author has access to the image.    
    if( ! twip.nil? and ! image.access_public_or_shared_with?( twip.author.identity_url))
      errors.add( "Image (#{image.id}/#{image.filename}) is not visible to Twip author (#{twip.author.identity_url})")
    end
  end
  
  def access_public_or_shared_with?( viewer_openid)
    # TODO: add conditions for sharing with other users
    authored = twip || image # determine which authored object governs access
    authored.access_public_or_shared_with?( viewer_openid)
  end
end
