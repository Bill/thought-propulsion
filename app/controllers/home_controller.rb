class HomeController < ApplicationController
  
  include ActionView::Helpers::SanitizeHelper
  
  layout 'home'
  
  def index
  end
  
  # these three actions are solely for testing the HTML/CSS layout of the alert div
  def error
    alert :error
  end
  def warn
    alert :warn
  end
  def inform
    alert :inform
  end
  
  protected
  def alert( category)
    flash[category] = sanitize( params[:msg])
    redirect_to request.referer || home_url
  end
end