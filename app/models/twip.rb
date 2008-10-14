class Twip < ActiveRecord::Base
  
  authored
  
  has_many :twips_viewers, :dependent => :destroy
  
  attr_protected :owner
  
  validates_presence_of :title
  
end