class Twip < ActiveRecord::Base
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  attr_protected :owner
end