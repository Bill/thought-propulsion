module Authored

  module ClassMethods
    # Unfortunately named_scopes don't work for in-memory ActiveRecords (before they've been successfully
    # saved). So we need a parallel set of methods that work for in-memory objects
    def access_shared_with?( viewer_openid)
      # TODO: add conditions for sharing with other users
      if viewer_openid.blank?
        false
      else
        author.identity_url == viewer_openid
      end
    end
    
    def access_public_or_shared_with?( viewer_openid)
      # TODO: add conditions for sharing with other users
      if viewer_openid.blank?
        public
      else
        public || author.identity_url == viewer_openid
      end
    end
  end

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
        # { :conditions => 'FALSE', :select => "#{table_name}.*", :joins => [:author] }
        { :conditions => 'FALSE', :joins => [:author] }
      else
        # { :conditions => {:identity_url => viewer_openid }, :select => "#{table_name}.*", :joins => [:author] }
        { :conditions => {:identity_url => viewer_openid }, :joins => [:author] }        
      end
    }

    # Um I wanted to do define just those two and let users combine them as they saw fit.
    # But since named_scopes can only be combined through conjunction (not disjunction), and since
    # there's no way to negate one of these things on the fly I had to combine them for the caller
    # TODO: add conditions for sharing with other users
    named_scope :access_public_or_shared_with, lambda{ |viewer_openid | 
      if viewer_openid.blank?
        # { :conditions => ["public = ?", true], :select => "#{table_name}.*"}
        { :conditions => ["public = ?", true]}
      else
        # { :conditions => ["public = ? OR identity_url = ?", true, viewer_openid], :select => "#{table_name}.*", :joins => [:author] }
        { :conditions => ["public = ? OR identity_url = ?", true, viewer_openid], :joins => [:author] }
      end
    }

    include ClassMethods
  end
end # Authored