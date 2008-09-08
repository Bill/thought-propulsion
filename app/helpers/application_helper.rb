# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include CorkdFormHelper
  
  def body_class
    # TODO: fix this once named routes are working again
    # route_name_for request.request_uri, :host => request.host
    case controller
    when HomeController, TwiplHomeController
      'home'
    when AboutController
      'why'
    when ContactController
      'contact'
    when TwipsController
      'blog'
    else
      ''
    end
  end
  
  def company_name
    "Thought Propulsion<span class='trademark'>&trade;</span>"
  end
  
  # this is just hard to generate because we need to move to another site and make sure we use the appropriate
  # port number. Maybe when we get the named route helpers working again this can go away.
  def thoughtpropulsion_url
    sub, port = Propel::EnvironmentSubdomains::envsub
    url_for( :controller => 'home', :action => 'index', :host => "#{sub}thoughtpropulsion.com", :port => port)
  end
  
  # ditto
  def thoughtpropulsion_blog_url
    sub, port = Propel::EnvironmentSubdomains::envsub
    url_for( :controller => 'home', :action => 'index', :host => "blog.#{sub}thoughtpropulsion.com", :port => port)
  end
  
  def thoughtpropulsion_contact_url
    sub, port = Propel::EnvironmentSubdomains::envsub
    url_for( :controller => 'contact', :action => 'index', :host => "#{sub}thoughtpropulsion.com", :port => port)
  end
  
  def thoughtpropulsion_why_url
    sub, port = Propel::EnvironmentSubdomains::envsub
    url_for( :controller => 'about', :action => 'index', :host => "#{sub}thoughtpropulsion.com", :port => port)
  end
  
  # override in your application's helper
  def product_name
    ''
  end
  
  def external_link_to( term, options={}, html_options={})
    html_options[:class] = add_class( html_options[:class])
    link_to term, options, html_options
  end
  
  def external_google_search_link_to( term, html_options={})
    html_options[:class] = add_class( html_options[:class])
    google_search_link_to term, html_options
  end

  def google_search_link_to( term, html_options={})
    link_to term, google_search_url_for( term), html_options
  end
  
  def google_search_url_for( term)
    "http://www.google.com/search?q=#{term}"
  end
  
  def co_branding_link( product_name, image_name)
    # override for Amazon Web Services in accordance w/ their ToS: http://www.amazon.com/gp/browse.html?node=360388011
    if( product_name == 'Amazon Web Services')
      url = 'http://aws.amazon.com'
    else
      url = google_search_url_for( product_name)
    end
    product_class = product_name.gsub(/\s+/, '-').downcase
    link_to image_tag( image_name, :class => "external #{product_class}", :alt => product_name), url, :title => product_name
  end
  
  private
  
  def add_class( classes_string)
    classes = (classes_string || '').split(' ')
    classes << 'external' unless classes.include?( 'external')
    classes.join(' ')
  end
  
end
