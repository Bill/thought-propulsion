module AirBlade
  module AirBudd
    
    LONG_FIELD_HELPERS = %w( text_field text_area password_field file_field
      date_select time_select )
    SHORT_FIELD_HELPERS = %w( check_box radio_button )
    COLLECTION_FIELD_HELPERS = %w( select )
    ALL_FIELD_HELPERS = LONG_FIELD_HELPERS + SHORT_FIELD_HELPERS + COLLECTION_FIELD_HELPERS
    
    # elides attributes
    # when you use this one, it's up to you go inject attributes into the containing element
    class EmptyWrapper
      def initialize( template)
        @template = template
      end
      
      # Guts copied from Rails 2.1.0 form_for. 
      # The purpose of this method is to let us wrap the content in a div and
      # to also make form tag optional
      def object( controls, scaffold, is_remote, record_or_name_or_array, *args, &proc)
        raise ArgumentError, "Missing block" unless block_given?

        options = args.extract_options!

        case record_or_name_or_array
        when String, Symbol
          object_name = record_or_name_or_array
        when Array
          object = record_or_name_or_array.last
          object_name = ActionController::RecordIdentifier.singular_class_name(object)
          @template.apply_form_for_options!(record_or_name_or_array, options)
          args.unshift object
        else
          object = record_or_name_or_array
          object_name = ActionController::RecordIdentifier.singular_class_name(object)
          @template.apply_form_for_options!([object], options)
          args.unshift object
        end

        wrapper_start( controls, scaffold, is_remote, options, object_name, &proc)
        @template.fields_for(object_name, *(args << options), &proc)
        wrapper_end( controls, scaffold, &proc)
      end
      def field( field_helper, content, attributes)
        content || '' # gotta turn nil into empty string or empty attribues cause exceptions
      end
      def value( field_helper, content, attributes)
        content || ''
      end
      
      protected
      def wrapper_start( controls, scaffold, is_remote, options, object_name, &proc)
        url, html = options.delete(:url), options.delete(:html)
        if controls
          if is_remote
            @template.concat( @template.form_remote_tag(options)) # see Rails prototype_helper.rb
          else
            @template.concat( @template.form_tag(url || {}, html || {})) # see Rails form_helper.rb
          end
        end
      end

      def wrapper_end( controls, scaffold, &proc)
        @template.concat('</form>') if controls
      end
    end

    class Wrapper < EmptyWrapper
      def field( field_helper, content, attributes)
        @template.content_tag( attribute_tag_for( field_helper), content, attributes)
      end
      def value( field_helper, content, attributes)
        @template.content_tag( value_tag_for( field_helper), content, attributes)
      end
      private
      def attribute_tag_for( field_helper)
        case field_helper
        when 'text_area': 'div' # content tag will be div so this can't be p
        else
          'p'
        end
      end
      def value_tag_for( field_helper)
        case field_helper
        when 'text_area': 'div' # in general these contain markup so we need divs
        else
          'span'
        end
      end
      protected
      def wrapper_start( controls, scaffold, is_remote, options, object_name, &proc)
        @template.concat("<div class='#{object_name}#{controls ? ' draft' : ' published' }'>")
        super
      end
      def wrapper_end( controls, scaffold, &proc)
        super
        @template.concat('</div>')
      end
    end

    class BaseBuilder < ActionView::Helpers::FormBuilder
      include Haml::Helpers if defined? Haml       # for compatibility
      include ActionView::Helpers::TextHelper      # so we can use concat
      include ActionView::Helpers::TagHelper       # CaptureHelper relies on block_called_from_erb?
      include ActionView::Helpers::CaptureHelper   # so we can use capture

      # App-wide form configuration.
      # E.g. in config/initializers/form_builder.rb:
      #
      #   AirBlade::AirBudd::FormBuilder.default_options[:required_signifier] = '*'
      #
      class_inheritable_reader      :default_options
      class_inheritable_hash_writer :default_options, :instance_writer => false
      class_inheritable_accessor    :wrapper_class

      self.default_options = { :label_suffix => ':'}
      self.wrapper_class = Wrapper
      
      attr_accessor :wrapper
      def initialize( *args, &proc)
        super
        self.wrapper = self.class.wrapper_class.new( @template )
      end

      # Rails' render_partial calls this (to_s) to find default form
      # when you do something like: render :partial => f (for some builder f)
      # By defining this as an unchanging value for this class and subclasses
      # we enable reuse of templates between form rendering and div rendering.
      def self.to_s
        'FormBuilder'
      end

      # Within the form's block you can get good buttons with:
      #
      #   <% f.buttons do |b| %>
      #     <%= b.save %>
      #     <%= b.cancel %>
      #   <% end %>
      #
      # You can have save, cancel, edit and delete buttons.
      # Each one takes an optional label.  For example:
      #
      #     <%= b.save :label => 'Update' %>
      #
      # See the documentation for the +button+ method for the
      # options you can use.
      #
      # You could call the button method directly, e.g. <%= f.button %>,
      # but then your button would not be wrapped with a div of class
      # 'buttons'.  The div is needed for the CSS.
      def buttons(&block)
        content = @template.capture(self, &block)
        @template.concat '<div class="buttons">'
        @template.concat content
        @template.concat '</div>'
      end

      # Buttons and links for REST actions.  Actions that change
      # state, i.e. save and delete, have buttons.  Other actions
      # have links.
      #
      # For visual feedback with colours and icons, save is seen
      # as a positive action; delete is negative.
      #
      # type = :new|:save|:cancel|:edit|:delete
      # TODO :all ?
      #
      # Options you can use are:
      #   :label - The label for the button or text for the link.
      #            Optional; defaults to capitalised purpose.
      #   :icon  - Whether or not to show an icon to the left of the label.
      #            Optional; icon will be shown unless :icon set to false.
      #   :url   - The URL to link to (only used in links).
      #            Optional; defaults to ''.
      def button(purpose = :edit, options = {}, html_options = {})
        # TODO: DRY the :a and :button.
        element, icon, nature = link_mapping( purpose )
        return unless element
        html_options.merge!(:class => nature)
        html_options.merge!(:href => (options[:url] || ''))
        @template.content_tag(element.to_s,
                              legend( options, icon, purpose ),
                              html_options)
      end

      def feedback( field)
        if errors_for? field
          error_msg = @object.errors[field].to_a.to_sentence
          option_capitalize = options.delete(:capitalize) || capitalize_errors
          error_msg = error_msg.capitalize unless option_capitalize == 'false' or option_capitalize == false
          %Q( <span class="feedback">#{error_msg}.</span>)
        else
          ''
        end
      end

      protected
      
      def link_mapping( purpose )
        case purpose
        when :new    then [:a,      'add',        'positive']
        when :cancel then [:a,      'arrow_undo', nil       ]
        when :edit   then [:a,      'pencil',     nil       ]
        end
      end
      
      def legend( options, icon, purpose)
        ( (options[:icon] == false || options[:icon] == 'false') ?
                   '' :
                   "<img src='/images/icons/#{icon}.png' alt=''/> " ) +
                 (options[:label] || purpose.to_s.capitalize)
      end

      def method_missing(*args, &block)
        if args.first.to_s =~ /^(new|save|cancel|edit|delete)$/
          button args.shift, *args, &block
        else
          super
        end
      end
      

      def data_type_for(field_helper)
        case field_helper
        when 'text_field';     'text attribute'
        when 'text_area';      'text attribute'
        when 'password_field'; 'password attribute'
        when 'file_field';     'file attribute'
        when 'hidden_field';   'hidden attribute'
        when 'check_box';      'checkbox attribute'
        when 'radio_button';   'radio attribute'
        when 'select';         'select attribute'
        when 'date_select';    'select date attribute'
        when 'time_select';    'select time attribute'
        else ''
        end
      end

      def attributes_for(method, field_helper)
        {:class => data_type_for(field_helper)} unless data_type_for(field_helper).blank?
      end

      # Writes out a <label/> element for the given field.
      # Options:
      #  - :required: text to indicate that field is required.  Optional: if not given,
      #  field is not required.  If set to true instead of a string, default indicator
      #  text is '(required)'.
      #  - :label: text wrapped by the <label/>.  Optional (default is field's name).
      #  - :suffix: appended to the label.  Optional (default is ':').
      #  - :capitalize: false if any error message should not be capitalised,
      #    true otherwise.  Optional (default is true).
      def label_element(field, options = {}, html_options = {})
        return '' if options.has_key?(:label) && options[:label].nil?
        text = options.delete(:label) || field.to_s.humanize
        suffix = options.delete(:suffix) || label_suffix
        value = text + suffix
        if (required = mandatory?( field, options.delete(:required)))
          required = required_signifier if required == true
          value += " <em class='required'>#{required}</em>"
        end

        html_options.stringify_keys!
        html_options['for'] ||= "#{@object_name}_#{field}"
        value += feedback( field)
        @template.content_tag :label, value, html_options
      end
      
      # Quack…Our callers (unlike folks expecting to be calling built-in Rails helpers)
      # may pass a block. If present, that block is delegated to to render non-control content.
      def self.create_field_helper(field_helper)
        # see our alias_method_chain below
        src = <<-END
          def #{field_helper}_with_buds(method, options, html_options = {}, &block)
            field( #{field_helper.inspect}, method, options, html_options, &block)
          end
        END
        class_eval src, __FILE__, __LINE__
      end

      def self.create_short_field_helper(field_helper)
        src = <<-END
          def #{field_helper}_with_buds(method, options, html_options = {}, &block)
            short_field( #{field_helper.inspect}, method, options, html_options, &block)
          end
        END
        class_eval src, __FILE__, __LINE__
      end

      def self.create_collection_field_helper(field_helper)
        src = <<-END
          def #{field_helper}_with_buds(method, choices, options, html_options = {}, &block)
            collection_field( #{field_helper.inspect}, method, choices, options, html_options, &block)
          end
        END
        class_eval src, __FILE__, __LINE__
      end

      LONG_FIELD_HELPERS.each do |name|
        create_field_helper name
      end

      SHORT_FIELD_HELPERS.each do |name|
        create_short_field_helper name
      end

      COLLECTION_FIELD_HELPERS.each do |name|
        create_collection_field_helper name
      end
      
      # We'll need handles to the original methods down in some subclasses
      ALL_FIELD_HELPERS.each{ |h| alias_method_chain h.to_sym, :buds}
      
    end # BaseBuilder

    # This is the builder used when :controls => false
    class DivBuilder < BaseBuilder
      
      # See this plugin's init.rb where we define this function to return true on
      #   ActionView::Helpers::FormBuilder
      def rendering_controls?
        false
      end
      
      self.wrapper_class = Wrapper
      
      # Per-form configuration (overrides app-wide form configuration).
      # E.g. in a form itself:
      #
      #   - airbudd_form_for @member do |f|
      #     - f.required_signifier = '*'
      #     = f.text_field :name
      #     ...etc...
      #
      attr_writer *default_options.keys
      default_options.keys.each do |field|
        src = <<-END_SRC
          def #{field}
            @#{field} || default_options[:#{field}]
          end
        END_SRC
        class_eval src, __FILE__, __LINE__
      end

      protected

      def field( field_helper, method, options, html_options = {})
        opts = options.stringify_keys
        
        #def InstanceTag#initialize(object_name, method_name, template_object, object = nil)
        ActionView::Helpers::InstanceTag.new( @object.class.name.downcase, method, self, options[:object]).send( :add_default_name_and_id, opts )
        value = @object.send( method)
        content = if block_given?
          yield value, :id => opts['id'], :class => 'value'
        else
          wrapper.value( field_helper,
            value, :id => opts['id'], :class => 'value' )
        end
        wrapper.field( field_helper, 
          label_element(method, options, html_options) + content,
          attributes_for(method, field_helper) )
      end

      def short_field( field_helper, method, options, html_options = {})
        opts = options.stringify_keys
        ActionView::Helpers::InstanceTag.new( @object.class.name.downcase, method, self, nil, options[:object]).send( :add_default_name_and_id, opts )
        value = @object.send( method)
        content = if block_given?
          yield value, :id => opts['id'], :class => 'value'
        else
          wrapper.value( field_helper,
            value, :id => opts['id'], :class => 'value')
        end
        wrapper.field( field_helper, 
          content + label_element(method, options, html_options),
          attributes_for(method, field_helper) )
      end

      def collection_field( field_helper, method, choices, options, html_options = {})
        opts = options.stringify_keys
        ActionView::Helpers::InstanceTag.new( @object.class.name.downcase, method, self, nil, options[:object]).send( :add_default_name_and_id, opts )
        value = @object.send( method)
        content = if block_given?
          yield value, :id => opts['id'], :class => 'value'
        else
          wrapper.value( field_helper,
            link_to( method, value ), :id => opts['id'], :class => 'value')
        end
        wrapper.field( field_helper, 
          label_element(method, options, html_options) + content,
          attributes_for(method, field_helper) )
      end

      # Don't ever display mandatory indicator when building :controls
      def mandatory?(method, override = nil)
        false
      end
      
      # Ignore errors when building :controls => false
      def errors_for?(method)
        nil
      end
      
    end # DivBuilder
    
    # This is the builder used when the :controls option true
    class FormBuilder < BaseBuilder

      self.wrapper_class = Wrapper

      # App-wide form configuration.
      # E.g. in config/initializers/form_builder.rb:
      #
      #   AirBlade::AirBudd::FormBuilder.default_options[:required_signifier] = '*'
      #
      self.default_options = {
        :required_signifier => '(required)',
        :capitalize_errors  => true
      }
      
      # Per-form configuration (overrides app-wide form configuration).
      # E.g. in a form itself:
      #
      #   - airbudd_form_for @member do |f|
      #     - f.required_signifier = '*'
      #     = f.text_field :name
      #     ...etc...
      #
      attr_writer *default_options.keys
      default_options.keys.each do |field|
        src = <<-END_SRC
          def #{field}
            @#{field} || default_options[:#{field}]
          end
        END_SRC
        class_eval src, __FILE__, __LINE__
      end
      
      def read_only_text_field(method_for_text_field, method_for_hidden_field = nil, options = {}, html_options = {})
        method_for_hidden_field ||= method_for_text_field
        @template.content_tag('p',
                              label_element(method_for_text_field, options, html_options) +
                              hidden_field(method_for_hidden_field, options) +
                              @template.content_tag('span', object.send(method_for_text_field)) +
                              addendum_element(options) +
                              hint_element(options),
                              attributes_for(method_for_text_field, 'text_field')
        )
      end
      
      # TODO: latitude_field, longitude_field must be defined on DivBuilder too

      # Support for GeoTools.
      # http://opensource.airbladesoftware.com/trunk/plugins/geo_tools/
      def latitude_field(method, options = {}, html_options = {})
        @template.content_tag('p',
          label_element(method, options, html_options) + (
              vanilla_text_field("#{method}_degrees",       options.merge(:maxlength => 2)) + '&deg;'   +
              vanilla_text_field("#{method}_minutes",       options.merge(:maxlength => 2)) + '.'       +
              vanilla_text_field("#{method}_milli_minutes", options.merge(:maxlength => 3)) + '&prime;' +
              # Hmm, we pass the options in the html_options position.
              vanilla_select("#{method}_hemisphere", %w( N S ), {}, options)
            ) +
            hint_element(options),
          (errors_for?(method) ? {:class => 'error'} : {})
        )
      end

      # Support for GeoTools.
      # http://opensource.airbladesoftware.com/trunk/plugins/geo_tools/
      def longitude_field(method, options = {}, html_options = {})
        @template.content_tag('p',
          label_element(method, options, html_options) + (
              vanilla_text_field("#{method}_degrees",       options.merge(:maxlength => 3)) + '&deg;'   +
              vanilla_text_field("#{method}_minutes",       options.merge(:maxlength => 2)) + '.'       +
              vanilla_text_field("#{method}_milli_minutes", options.merge(:maxlength => 3)) + '&prime;' +
              # Hmm, we pass the options in the html_options position.
              vanilla_select("#{method}_hemisphere", %w( E W ), {}, options)
            ) +
            hint_element(options),
          (errors_for?(method) ? {:class => 'error'} : {})
        )
      end
      
      def button(purpose = :save, options = {}, html_options = {})
        return super || begin
          element, icon, nature = button_mapping( purpose )
          return unless element
          html_options.merge!(:class => nature)
          html_options.merge!(:type => 'submit')
          @template.content_tag(element.to_s,
                                legend( options, icon, purpose),
                                html_options)
          end
      end
      
      protected
      
      def button_mapping( purpose)
        case purpose
        when :save   then [:button, 'tick',       'positive']
        when :delete then [:button, 'cross',      'negative']
        end
      end

      # Creates a glorified form field helper.  It takes a form helper's usual
      # arguments with an optional options hash:
      #
      # <%= form.text_field 'title',
      #                     :required => true,
      #                     :label    => "Article's Title",
      #                     :hint     => "Try not to use the letter 'e'." %>
      #
      # The code above generates the following HTML.  The :required entry in the hash
      # triggers the <em/> element and the :label overwrites the default field label,
      # 'title' in this case, with its value.  The stanza is wrapped in a <p/> element.
      #
      # <p class="text">
      #   <label for="article_title">Article's Title:
      #     <em class="required">(required)</em>
      #   </label>
      #   <input id="article_title" name="article[title]" type="text" value=""/>
      #   <span class="hint">Try not to use the letter 'e'.</span>
      # </p>
      #
      # If the field's value is invalid, the <p/> is marked so and a <span/> is added
      # with the (in)validation message:
      #
      # <p class="error text">
      #   <label for="article_title">Article's Title:
      #     <em class="required">(required)</em>
      #     <span class="feedback">can't be blank</span>
      #   </label>
      #   <input id="article_title" name="article[title]" type="text" value=""/>
      #   <span class="hint">Try not to use the letter 'e'.</span>
      # </p>
      #
      # You can also pass an :addendum option.  This generates a <span/> between the
      # <input/> and the hint.  Typically you would use this to show a small icon
      # for deleting the field.
      def field( field_helper, method, options, html_options = {})
        content = wrapper.value( field_helper,
          # invoke a Rails built-in control generator
          send( "#{field_helper}_without_buds", method, options), :class => 'value')
        wrapper.field( field_helper, 
          label_element(method, options, html_options) +
          content +
          addendum_element(options) +
          hint_element(options),
          attributes_for(method, field_helper) )
      end

      def short_field( field_helper, method, options, html_options = {})
        content = wrapper.value( field_helper,
          send( "#{field_helper}_without_buds", method, options), :class => 'value')
        wrapper.field( field_helper, 
          content +
          label_element(method, options, html_options) +
          hint_element(options),
          attributes_for(method, field_helper) )
      end

      def collection_field( field_helper, method, choices, options, html_options = {})
        content = wrapper.value( field_helper,
          send( "#{field_helper}_without_buds", method, choices, options), :class => 'value')
        wrapper.field( field_helper, 
          label_element(method, options, html_options) +
          content +
          addendum_element(options) +
          hint_element(options),
          attributes_for(method, field_helper) )
      end

      def attributes_for(method, field_helper)
        result = super
        result[:class] = ( ((result || {})[:class] || '').split << 'error')*' ' if errors_for?(method)
        result
      end

      def mandatory?(method, override = nil)
        return override unless override.nil?
        # Leverage vendor/validation_reflection.rb
        if @object.class.respond_to? :reflect_on_validations_for
          @object.class.reflect_on_validations_for(method).any? { |val| val.macro == :validates_presence_of } 
        end
      end

      # Writes out a <span/> element with a hint for how to fill in a field.
      # Options:
      #  - :hint: text for the hint.  Optional.
      def hint_element(options = {})
        hint = options.delete :hint
        if hint
          @template.content_tag :span, hint, :class => 'hint'
        else
          ''
        end
      end

      # Writes out a <span/> element with something that follows a field.
      # Options:
      #  - :hint: text for the hint.  Optional.
      def addendum_element(options = {})
        addendum = options.delete :addendum
        if addendum
          @template.content_tag :span, addendum, :class => 'addendum'
        else
          ''
        end
      end

      def errors_for?(method)
        @object && @object.errors[method]
      end

      alias_method :vanilla_text_field,   :text_field
      alias_method :vanilla_select,       :select

    end
  end
end
