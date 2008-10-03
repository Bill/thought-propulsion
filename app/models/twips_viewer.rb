class TwipsViewer < ActiveRecord::Base
  
  belongs_to :twip
  
  validates_presence_of :viewer_openid
  
  validates_uniqueness_of :viewer_openid, :scope => :twip_id
  
  def viewer_openid=( url)
    self[:viewer_openid] = URL.normalize_url( url)
  end
  
end