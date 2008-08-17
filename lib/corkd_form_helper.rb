module CorkdFormHelper

  # Guts copied from Rails 2.1.0 form_for. The purpose of this is to let us put a table inside the form
  def corkd_form_for(record_or_name_or_array, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?

    options = args.extract_options!

    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
    when Array
      object = record_or_name_or_array.last
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
      apply_form_for_options!(record_or_name_or_array, options)
      args.unshift object
    else
      object = record_or_name_or_array
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
      apply_form_for_options!([object], options)
      args.unshift object
    end

    concat(form_tag(options.delete(:url) || {}, options.delete(:html) || {}), proc.binding)
    corkd_form_start( &proc)
    fields_for(object_name, *(args << options), &proc)
    corkd_form_end( &proc)
    concat('</form>', proc.binding)
  end
  
  def corkd_form_start( &proc)
    concat('<table class="form-table"><tbody>', proc.binding)
  end
  def corkd_form_end( &proc)
    concat('</tbody></table>', proc.binding)
  end
  
end