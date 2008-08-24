# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include CorkdFormHelper
  
  def body_class
    route_name_for :controller => params[:controller], :action => params[:action]
  end
  
  def company_name
    "Thought Propulsion<span class='trademark'>&trade;</span>"
  end
  
  def page_title
    "iPhone &amp; Web Apps Built About You"
  end
  
  def google_search_link_to( term, options={})
    link_to term, google_search_url_for( term), options
  end
  
  def google_search_url_for( term)
    "http://www.google.com/search?q=#{term}"
  end
  
end
