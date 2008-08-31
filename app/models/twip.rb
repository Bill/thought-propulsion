class Twip < ActiveRecord::Base
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  has_many :twips_viewers, :dependent => :destroy
  
  attr_protected :owner

  # TODO: add conditions
  named_scope :access_public, { :conditions => {:public => true}}
  # TODO: add conditions
  named_scope :access_shared_with, lambda{ |viewer_openid| {}}
  
  # Um I wanted to do define just those two and let users combine them as they saw fit.
  # But since named_scopes can only be combined through conjunction (not disjunction), and since
  # there's no way to negate one of these things on the fly I had to combine them for the caller
  # TODO: add conditions
  named_scope :access_public_or_shared_with, lambda{ |viewer_openid| { :conditions => {:public => true}}}
end