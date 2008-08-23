class User < ActiveRecord::Base
  
  validates_presence_of :identity_url, :nickname
  
  validates_uniqueness_of :identity_url, :nickname
end