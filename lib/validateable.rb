module Validateable
  [:save, :save!, :update_attribute].each{|attr| define_method(attr){}}
  def method_missing(symbol, *params)
    if(symbol.to_s =~ /(.*)_before_type_cast$/)
      send($1)
    end
  end
  module ClassMethods
    def human_attribute_name(attribute_key_name)
      attribute_key_name.humanize
    end
  end
  def self.included(base)
    base.send(:include, ActiveRecord::Validations)
    base.extend(ClassMethods)
  end
end