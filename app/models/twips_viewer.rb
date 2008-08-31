class TwipsViewer < ActiveRecord::Base
  
  belongs_to :twip
  
  validates_presence_of :viewer_openid
  
  validates_uniqueness_of :viewer_openid, :scope => { :twip_id}
  
end