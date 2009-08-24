module Netzke
  module PropertyEditorExtras 
    class HelperModel
      def self.widget=(w)
        @@widget = w
      end
      
      def self.widget
        @@widget ||= raise RuntimeError, "No widget specified for PropertyEditorExtras::HelperModel"
      end
      
      def self.reflect_on_all_associations
        []
      end
      
      def self.primary_key
        "id"
      end
      
      def self.netzke_exposed_attributes
        preferences = self.widget.flat_default_config
        # preferences = NetzkePreference.find_all_for_widget(widget.name)
        preferences.each { |p| p.reject!{ |k,v| k == :value}.merge!(:field_label => p[:name].to_s.gsub('__', "/").humanize) }
        preferences
      end

      DEFAULTS_FOR_FIELD = {
        :Fixnum => {
          :xtype => :numberfield
        },
        :Boolean => {
          :xtype => :xcheckbox,
          :checked => true
        },
        :String => {
          :xtype => :textfield
        }
      }

      # DRY out!
      def self.default_field_config(config)
        type = config.delete(:type)

        common = {
          :field_label => config[:name].to_s.gsub('__', '_').humanize,
          :hidden      => config[:name] == :id
        }

        default = DEFAULTS_FOR_FIELD[type] || DEFAULTS_FOR_FIELD[:String] # fallback to plain textfield

        res = default.merge(common).merge(config)
      end
  
      def self.find_by_id(*args)
        self.new
      end
  
      def save
      end
  
      def errors
        a = Array.new
        def a.each_full
          []
        end
        a
      end
  
      def to_array(columns)
        res = []
        for c in columns
          method = c.is_a?(Symbol) ? c : c[:name]
          value = send(method)
          res << (value.is_a?(Array) || value.is_a?(Hash) ? value.to_json : value)
        end
        res
      end

      # somewhat sofisticated code to convert all NetzkePreferences for current widget into a hash ("un-flatten")
      def attributes
        prefs = NetzkePreference.find_all_for_widget(self.class.widget.id_name)
        res = {}
        prefs.each do |p|
          tmp_res = {}
          hsh_levels = p.name.split("__").map(&:to_sym)
          hsh_levels.each do |level_prefix|
            tmp_res[level_prefix] ||= level_prefix == hsh_levels.last ? p.normalized_value : {}
            res[level_prefix] = tmp_res[level_prefix] if level_prefix == hsh_levels.first
            tmp_res = tmp_res[level_prefix]
          end
        end
        res
      end

      def method_missing(method_name, *args)
        # Rails.logger.debug "!!! method_name: #{method_name.inspect}"
        method_name = method_name.to_s
        method_name_without_equal_sign = method_name.sub(/=$/, '')
        NetzkePreference.widget_name = self.class.widget.id_name

        if method_name =~ /=$/
          # current_value = NetzkePreference[method_name_without_equal_sign] # may be nil
          current_value = self.class.widget.flat_independent_config(method_name_without_equal_sign)
          
          begin
            new_value = ActiveSupport::JSON.decode(args.first) # TODO: provide feedback about this error
          rescue ActiveSupport::JSON::ParseError
            new_value = current_value
          end
          
          # default_value = self.class.widget.flat_default_config(method_name_without_equal_sign)
          initial_value = self.class.widget.flat_initial_config(method_name_without_equal_sign)
      
          # Rails.logger.debug "!!! current_value: #{current_value.inspect}"
          # Rails.logger.debug "!!! new_value: #{new_value.inspect}"
          # Rails.logger.debug "!!! initial_value: #{initial_value.inspect}"
      
          new_value = nil if new_value == initial_value
          # Rails.logger.debug "!!! new_value: #{new_value.inspect}"
          NetzkePreference[method_name_without_equal_sign] = new_value
        else
          res = self.class.widget.flat_independent_config(method_name_without_equal_sign)
          res = ActiveSupport::JSON.encode(res) if res.is_a?(Array) || res.is_a?(Hash)
          res
        end
      end
  
    end
  end
end