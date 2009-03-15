module Netzke
  module PropertyEditorExtras 
    class HelperModel
      def self.widget_name=(name)
        @@widget_name = name
      end
  
      def self.exposed_columns
        # preferences = NetzkePreference.all
        preferences = NetzkePreference.find_all_by_widget_name(@@widget_name)
        preferences.map{|p| {
          :name => p.name,
          :field_label => p.name.gsub('__', "/").humanize,
          :type => p.pref_type.to_sym
        }}
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
  
      def self.find_by_id(args)
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
        Rails.logger.debug "!!! columns: #{columns.inspect}"
        res = []
        for c in columns
          method = c.is_a?(Symbol) ? c : c[:name]
          value = send(method)
          res << (value.is_a?(Array) || value.is_a?(Hash) ? value.to_json : value)
        end
        res
      end

      def method_missing(method_name, *args)
        method_name = method_name.to_s
        method_name_without_equal_sign = method_name.sub(/=$/, '')
        NetzkePreference.widget_name = @@widget_name

        if method_name =~ /=$/
          current_value = NetzkePreference[method_name_without_equal_sign]
          new_value = args.first
      
          # JSON-parse if we expect an Array on Hash
          new_value = JSON.parse(new_value) if current_value.is_a?(Array) || current_value.is_a?(Hash) # TODO: validate JSON
      
          # convert to true/false if expecting a Boolean
          new_value = {"false" => false, "true" => true}[new_value] if current_value.is_a?(TrueClass) || current_value.is_a?(FalseClass)

          NetzkePreference[method_name_without_equal_sign] = new_value
        else
          NetzkePreference[method_name_without_equal_sign]
        end
      end
  
    end
  end
end