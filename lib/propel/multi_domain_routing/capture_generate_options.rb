module Propel
  module MultiDomainRouting
    module CaptureGenerateOptions
      
      attr_accessor :current_generate_options
      
      def self.included( other)
        other.alias_method_chain :generate, :remember_options
      end
      
      def generate_with_remember_options(options, recall = {}, method=:generate)
        # yeah, I'm doing this…
        self.current_generate_options = options
        returning( generate_without_remember_options( options, recall, method) ) do
          self.current_generate_options = nil
        end
      end
    end
  end
end

