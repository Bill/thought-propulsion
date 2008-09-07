class User < ActiveRecord::Base
  
  validates_presence_of :identity_url, :normalized_identity_url
  
  validates_uniqueness_of :normalized_identity_url, :nickname
  
  validates_each :alternate_domain do | record, attr, value |
    record.errors.add attr, "sorry, #{value} is already spoken for" if !value.blank? && User.with_alternate_domain( value).count > 0
  end
  
  validates_each :nickname do | record, attr, value | 
    record.errors.add attr, DomainName::LABEL_INSTRUCTIONS unless DomainName::valid_label?( value)
  end
  
  attr_protected :admin, :identity_url, :normalized_identity_url, :alternate_domain
  
  has_many :twips, :foreign_key => 'owner_id', :dependent => :destroy
  
  named_scope :with_same_identity, lambda{ |user| { :conditions => { :normalized_identity_url => user.normalized_identity_url}}}
  
  named_scope :for_host, lambda { |host_from_request|
    # using criteriaquery plugin
    q = User.query
    q.disjunction.nickname_eq( DomainName.bottom_label(host_from_request) ).alternate_domain_eq( host_from_request )
    q.find_options
  }

  named_scope :with_alternate_domain, lambda{|domain| { :conditions => { :alternate_domain => domain }}}

  def initialize( *args)
    super( *args)
    self.authenticator ||= Propel::Nonce.generate
  end

  def set_sensitive_parameters( user_parameters, registered_user, authenticated_identity_url)
    # if _logged-in_ user is admin then shey can edit any user's alternate_domain
    if( registered_user && registered_user.admin )
      self.alternate_domain = user_parameters[:alternate_domain]
    end
  end
  
  def identity_url=(url)
    super
    self[:normalized_identity_url] = URL.normalize_url(url)
  end

  # The domain that this user's Twips are visible (to others) on. Each user starts with this one and may
  # purchase additional ones.
  def twipl_domain
    # this logic needs to be the inverse of the logic in the :for_host named scope
    sub, port = Propel::EnvironmentSubdomains::envsub
    nickname ? "http://#{nickname}.#{sub}twipl.com#{port ? ":#{port}" : ''}" : '(you must specify a nickname in order to have a subdomain)'
  end
  
end