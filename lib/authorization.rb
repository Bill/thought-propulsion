module Authorization

  def self.included(other)
    other.helper_method :user_is_registered, :user_is_admin, :user_is_admin_or_authorized_for_action
  end

  # This is the second level of authority: the principal is authenticated and has a User object in the system
  def filter_user_is_registered
    unless( user_is_registered)
      redirect_to_login
    end
  end
  
  # And finally, the highest authority level: the administrative user. Admin can only be designated via
  # the console since the attribute is protected and there is no UI to edit it.
  def filter_user_is_admin
    # We aren't going to redirect on this one. Since it's an admin interface it's pretty sensitive so 
    # we're going to give a "not found" response (security through obscurity anyone?)
    unless( user_is_admin)
      respond_to do |wants|
        wants.atom { head 404}
        wants.atomsvc { head 404}
        wants.html do
          render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
        end
      end
    end
  end
  
  def filter_user_is_admin_or_authorized_for_action
    unless( user_is_admin_or_authorized_for_action)
      respond_to do |wants|
        wants.atom { head 403}
        wants.atomsvc { head 403}
        wants.html do
          render :file => "#{RAILS_ROOT}/public/403.html", :status => 403
        end
      end
    end
  end
  
  def user_is_registered
    user_is_authenticated && ! registered_user.blank?
  end
  
  def user_is_admin
    registered_user && registered_user.admin
  end

  def user_is_admin_or_authorized_for_action
    user_is_registered && ( registered_user.admin || user_action_on_resource_authorized)
  end
  
  # Override in controllers. Look at params and return true/false if registered_user
  # can perform action
  def user_action_on_resource_authorized
  end

  protected
  
  def filter_for_condition( message, &block)
    unless( yield block)
      error message, :after_redirect
      # FIXME: url helper
      redirect_to url_for( '/')
    end
  end
  
end