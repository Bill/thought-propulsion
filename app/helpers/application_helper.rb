# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include CorkdFormHelper
  
  def body_class
    # This abomination does a reverse-lookup to find the named route (name) from the current
    # controller and action. The is preferrable to just munging the controller name since often
    # your named routes (names) evolve somewhat independently of your controller names over time.
    controller_name = params[:controller]
    action_name = params[:action]
    routes = ActionController::Routing::Routes.named_routes.routes
    options = {:controller => controller_name, :action => action_name}
    found = routes.find do |route_name, route|
      route.generate( options, options) # ignore "recall" issues (see Rails route_set.rb)
    end
    found[0] || ''
  end
  
  def company_name
    "Thought Propulsion<span class='trademark'>&trade;</span>"
  end
  
  def page_title
    "iPhone &amp; Web Apps Built About You"
  end
  
  # def error_handling_form_for(record_or_name_or_array, *args, &proc)
  def error_handling_form_for(record_or_name_or_array, *args, &proc)
    options = args.detect { |argument| argument.is_a?(Hash) }
    if options.nil?
      options = {:builder => CorkdFormBuilder}
      args << options
    end
    options[:builder] = CorkdFormBuilder unless options.nil?
    corkd_form_for( record_or_name_or_array, *args, &proc)
  end
  
end
