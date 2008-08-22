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
  
end
