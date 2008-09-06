# pulled from rails (post 2.1.0) edge week of 9/6/2008
module ActiveSupport
  class OptionMerger
    instance_methods.each do |method|
      undef_method(method) if method !~ /^(__|instance_eval|class|object_id)/
    end
 
    def initialize(context, options)
      @context, @options = context, options
    end
 
    private
      def method_missing(method, *arguments, &block)
        arguments << (arguments.last.respond_to?(:to_hash) ? @options.deep_merge(arguments.pop) : @options.dup)
        @context.__send__(method, *arguments, &block)
      end
  end
end