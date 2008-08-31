class User < ActiveRecord::Base
  
  validates_presence_of :identity_url, :normalized_identity_url
  
  validates_uniqueness_of :normalized_identity_url, :nickname
  
  validates_each :nickname do | record, attr, value | 
    record.errors.add attr, DomainName::LABEL_INSTRUCTIONS unless DomainName::valid_label?( value)
  end
  
  attr_protected :admin, :identity_url, :normalized_identity_url
  
  has_many :twips, :foreign_key => 'owner_id', :dependent => :destroy
  
  named_scope :with_same_identity, lambda{ |user| { :conditions => { :normalized_identity_url => user.normalized_identity_url}}}
  named_scope :for_host, lambda{ |host_from_request| { :conditions => { :nickname => DomainName.bottom_label(host_from_request)}}}

  def initialize( *args)
    super( *args)
    self.authenticator ||= Nonce.generate
  end
  
  def identity_url=(url)
    super
    self[:normalized_identity_url] = normalize_url(url)
  end
  
  protected
  
  def normalize_url( url)
    url = url[0..-2] unless url.nil? || (url[-1].chr != '/')
    # see http://gbiv.com/protocols/uri/rfc/rfc3986.html#scheme
    scheme = /[[:alpha:]]([[:alpha:]]|[[:digit:]]|\+|\-|\.)*:/.match url
    if scheme
      url
    else
      'http://' + url
    end
  end
end