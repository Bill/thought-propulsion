class Image < ActiveRecord::Base
  
  authored

  PROCESSOR = (ENV["RAILS_ENV"] == 'test' ? 'ImageScience' : 'Rmagick')

  has_attachment :processor => PROCESSOR,
                 :s3_access => :authenticated_read,
                 :content_type => :image, 
                 :storage => :s3, 
                 :max_size => 500.kilobytes,
                 :resize_to => '320x200>',
                 :thumbnails => { :thumb => '100x100>' },
                 :thumbnail_class => ThumbnailImage
  
  validates_as_attachment
  
  
  # TODO: use attr_protected :owner once it doesn't clash with attachment-fu
  #   <RuntimeError: Declare either attr_protected or attr_accessible for Image, but not both.>
  # attr_protected :owner
end