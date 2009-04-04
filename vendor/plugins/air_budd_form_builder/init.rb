require 'vendor/validation_reflection'
# We explicitly require form_builder.rb since it defines multiple classes. Failure to do this
# causes e.g. BaseBuilder to be undefined in config/initializers
require 'air_blade/air_budd/form_builder'
require 'air_blade/air_budd/form_helper'

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }

ActionView::Base.send :include, AirBlade::AirBudd::FormHelper

ActionView::Helpers::FormBuilder.class_eval do
  # so that forms can test their mode. overridden in some subclasses.
  def rendering_controls?
    true
  end
end