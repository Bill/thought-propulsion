# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include CorkdFormHelper
  
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
