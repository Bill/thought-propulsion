class ThumbnailImage < ActiveRecord::Base
  
  has_attachment :processor => Image::PROCESSOR,
                 :s3_access => :authenticated_read,
                 :content_type => :image, 
                 :storage => :s3, 
                 :max_size => 50.kilobytes
  
  validates_as_attachment
end