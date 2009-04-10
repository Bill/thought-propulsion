class Twip < ActiveRecord::Base
  
  authored
  
  has_many :twips_viewers, :dependent => :destroy
  
  has_many :image_placements
  
  attr_protected :owner
  
  validates_presence_of :title
  validates_associated :image_placements
end