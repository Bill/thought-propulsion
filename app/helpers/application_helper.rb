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

  def external_google_search_link_to( term, options={})
    options[:class] = add_class( options[:class])
    google_search_link_to term, options
  end

  def google_search_link_to( term, options={})
    link_to term, google_search_url_for( term), options
  end
  
  def google_search_url_for( term)
    "http://www.google.com/search?q=#{term}"
  end
  
  def co_branding_link( product_name, image_name)
    product_class = product_name.gsub(/\s+/, '-').downcase
    link_to image_tag( image_name, :class => "external #{product_class}"), google_search_url_for( product_name)
  end
  
  private
  
  def add_class( classes_string)
    classes = (classes_string || '').split(' ')
    classes << 'external' unless classes.include?( 'external')
    classes.join(' ')
  end
  
end
