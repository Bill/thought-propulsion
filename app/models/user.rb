class User < ActiveRecord::Base
  
  validates_presence_of :identity_url, :nickname
  
  validates_uniqueness_of :identity_url, :nickname
  
  attr_protected :admin, :identity_url
  
  has_many :twips, :foreign_key => 'owner_id'

  def initialize(*args)
    super(*args)
    self.authenticator ||= Nonce.generate
  end
end