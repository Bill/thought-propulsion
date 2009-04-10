class ThumbnailImage < ActiveRecord::Base
  
  # PROCESSOR is set by a custom Rails initializer (see the /config/initializers directory)
  
  has_attachment :processor => Image::processor,
                 :s3_access => :authenticated_read,
                 :content_type => :image, 
                 :storage => :s3, 
                 :max_size => 50.kilobytes
  
  validates_as_attachment
end