# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include CorkdFormHelper
  
  def datetime( time)
    "#{date(time)} | #{time(time)}"
  end
  
  def date( time)
    time.strftime( "<span class='month span-1 last'>%b</span> <span class='day span-1 last'>%d</span>, <span class='year'>%Y</span>")
  end
  
  def time( time)
    # see http://microformats.org/wiki/datetime-design-pattern
    "<abbr class='time' title='#{ time.to_s }'>#{time.strftime( '%I:%M %p')}</abbr>"
  end
  
  def google_analytics_site_identifier
    # TODO: add twipl.com
    # TODO: expand this logic to lookup code for the publisher (for Twipl) to cover all Twipl subdomains
    #       and Twipl user alternate domains too
    ua_code = case ENV['RAILS_ENV']
    when 'production'
      "UA-184449-4" # thoughtpropulsion.com
    when 'staging'
      "UA-184449-5" # staging.thoughtpropulsion.com
    end
    "var pageTracker = _gat._getTracker('#{ua_code}');"
  end
  
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
  
  # TODO: this value should be set in routes.rb as :page_title (SET_DEFAULT_NOT_IN_PATTERN_FOILS_URL_GENERATION)
  def page_title
    envsub, port = Propel::EnvironmentSubdomains::envsub
    envsub = Regexp.escape(envsub) # we're gonna use envsub as part of a Regexp
    case request.host
    when /^blog\.#{envsub}thoughtpropulsion.com$/
      case controller
      when OpenidsController: 'Thought Propulsion | Sign Up'
      when UsersController:   'Thought Propulsion | Your Account'
      else
        'Thought Propulsion | Blog'
      end
    when /^#{envsub}thoughtpropulsion.com$/
      case controller
      when OpenidsController: 'Thought Propulsion | Sign Up'
      when UsersController:   'Thought Propulsion | Your Account'
      when AboutController:   'Thought Propulsion | Why We Do It'
      when ContactController: 'Thought Propulsion | Contact'
      else
        'Thought Propulsion | iPhone &amp; Web Apps Built About You'
      end
    when /^#{envsub}twipl.com$/
      case controller
      when OpenidsController: 'Twipl | Sign Up'
      when UsersController:   'Twipl | Your Account'
      else
        'Twipl | Authoring Built About You'
      end
    when /((.+)\.)#{envsub}twipl.com$/
      case controller
      when OpenidsController: "#{$2} | Sign Up"
      when UsersController:   "#{$2} | Your Account"
      else
        "#{$2} | Powered by Twipl"
      end
    else
      'Powered by Twipl'
    end
  end
  
  def company_name
    "Thought Propulsion<span class='trademark'>&trade;</span>"
  end
  
  # TODO: this shouldn't be necessary (RAILS_MULTIPLE_ROUTES_PER_NAME_BROKEN)
  # this is just hard to generate because we need to move to another site and make sure we use the appropriate
  # port number. Maybe when we get the named route helpers working again this can go away.
  def thoughtpropulsion_url
    sub, port = Propel::EnvironmentSubdomains::envsub
    url_for( :controller => 'home', :action => 'index', :host => "#{sub}thoughtpropulsion.com", :port => port)
  end
  
  # TODO: this shouldn't be necessary (RAILS_MULTIPLE_ROUTES_PER_NAME_BROKEN)
  def thoughtpropulsion_blog_url
    sub, port = Propel::EnvironmentSubdomains::envsub
    url_for( :controller => 'home', :action => 'index', :host => "blog.#{sub}thoughtpropulsion.com", :port => port)
  end
  
  # TODO: this shouldn't be necessary (RAILS_MULTIPLE_ROUTES_PER_NAME_BROKEN)
  def thoughtpropulsion_contact_url
    sub, port = Propel::EnvironmentSubdomains::envsub
    url_for( :controller => 'contact', :action => 'index', :host => "#{sub}thoughtpropulsion.com", :port => port)
  end
  
  # TODO: this shouldn't be necessary (RAILS_MULTIPLE_ROUTES_PER_NAME_BROKEN)
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
