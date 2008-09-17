class HomeController < ThoughtPropulsionApplicationController
  
  include ActionView::Helpers::SanitizeHelper
  
  def index
  end
  
  # these three actions are solely for testing the HTML/CSS layout of the alert div
  def error
    alert :error, sanitize( params[:msg])
    render :action => 'index'
  end
  def warn
    alert :warn, sanitize( params[:msg])
    render :action => 'index'
  end
  def inform
    alert :inform, sanitize( params[:msg])
    render :action => 'index'
  end
end