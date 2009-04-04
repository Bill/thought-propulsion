module AirBlade
  module AirBudd
    module FormHelper

      def airbudd_form_for(record_or_name_or_array, *args, &proc)
        x_form_for( false, record_or_name_or_array, *args, &proc )
      end

      def airbudd_remote_form_for(record_or_name_or_array, *args, &proc)
        x_form_for( true, record_or_name_or_array, *args, &proc )
      end

      def airbudd_fields_for(record_or_name_or_array, *args, &proc)
        # Well we don't do very well unles we use Procs instead of blocks, hence the Proc and lambda
        with_fields_for_options( lambda { | builder, controls, scaffold, record_or_name_or_array, args, original_callers_proc |
            # careful! don't call super with our original arguments (call w/ modified ones)
            fields_for record_or_name_or_array, *args, &original_callers_proc.binding
        }, record_or_name_or_array, args, Proc.new( &proc ) )
      end

      # Displays a link visually consistent with AirBudd form links.
      # TODO: complete this.  See README.
      # TODO: DRY with FormBuilder#button implementation.
      def link_to_form(purpose, options = {}, html_options = nil)
        icon = case purpose
               when :new    then 'add'
               when :edit   then 'pencil'
               when :delete then 'cross'  # TODO: delete should be a button, not a link
               when :cancel then 'arrow_undo'
               end
        if options.kind_of? String
          url = options
        else
          url = options.delete :url
          label = options.delete :label
        end
        label ||= purpose.to_s.capitalize
        legend = ( icon.nil? ?
                   '' :
                   "<img src='/images/icons/#{icon}.png' alt=''></img> " ) + label
        
        '<div class="buttons">' +
        link_to(legend, (url || options), html_options) +
        '</div>'
      end
      
      protected
      
      def x_form_for( is_remote, record_or_name_or_array, *args, &proc)
        # can't call a method w/ two blocks--one's gotta be a Proc
        with_fields_for_options( lambda{ | builder, controls, scaffold, record_or_name_or_array, args, original_callers_proc |
          # wrap( wrapper, controls, scaffold, is_remote, record_or_name_or_array, *args, &original_callers_proc.binding)
          builder.wrapper_class.new( self ).object( controls, scaffold, is_remote, record_or_name_or_array, *args, &original_callers_proc.binding)
        }, record_or_name_or_array, args, Proc.new( &proc ) )
      end
      
      # Options processing for form_for, fields_for etc. is complicated. This method
      # isolates those complications. NB we take a two proc parameters. direct_callers_proc
      # is from the direct caller and original_callers_proc is from the original caller
      def with_fields_for_options( direct_callers_proc, record_or_name_or_array, args, original_callers_proc)
        options = args.detect { |argument| argument.is_a?(Hash) }
        if options.nil? # if caller didn't send options, append our own Hash
          options = {}
          args << options
        end
        options.reverse_merge! :controls => true, :scaffold => true # defaults
        controls = options.delete(:controls)
        scaffold = options.delete(:scaffold)
        builder = ( controls ? AirBlade::AirBudd::FormBuilder : AirBlade::AirBudd::DivBuilder)
        builder = ( returning( Class.new( builder ) ) { |c| 
          c.wrapper_class = AirBlade::AirBudd::EmptyWrapper } ) unless scaffold
        options[:builder] = builder
        direct_callers_proc.call builder, controls, scaffold, record_or_name_or_array, args, original_callers_proc
      end
    end
  end
end
