module Authored
  def authored
    
    belongs_to :author, :class_name => 'User', :foreign_key => 'owner_id'
    
    validates_presence_of :author
    
    named_scope :access_public, { :conditions => {:public => true}}

    # Note that a object is "shared with" its author implicitly so we need to join to user
    # TODO: add conditions for sharing with other users
    named_scope :access_shared_with, lambda{ |viewer_openid| 
      # we have to use :select to help Rails 2.1.0 not get confused about which attributes go w/ which table
      # http://selfamusementpark.com/blog/2008/07/10/named_scope-joins-includes/
      if viewer_openid.blank?
        { :conditions => 'FALSE', :select => "#{table_name}.*", :joins => [:author] }
      else
        { :conditions => {:identity_url => viewer_openid }, :select => "#{table_name}.*", :joins => [:author] }
      end
    }

    # Um I wanted to do define just those two and let users combine them as they saw fit.
    # But since named_scopes can only be combined through conjunction (not disjunction), and since
    # there's no way to negate one of these things on the fly I had to combine them for the caller
    # TODO: add conditions for sharing with other users
    named_scope :access_public_or_shared_with, lambda{ |viewer_openid | 
      if viewer_openid.blank?
        { :conditions => "public = 't'", :select => "#{table_name}.*"}
      else
        { :conditions => ["public = 't' OR identity_url = ?", viewer_openid], :select => "#{table_name}.*", :joins => [:author] }
      end
    }
  end
end # Authored