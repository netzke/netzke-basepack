module Netzke
  class PropertyEditor < FormPanel
    class HelperModel
      def self.component=(w)
        @@component = w
      end
      
      def self.component
        @@component ||= raise RuntimeError, "No component specified for PropertyEditor::HelperModel"
      end
      
      def self.reflect_on_all_associations
        []
      end
      
      def self.primary_key
        "id"
      end
      
      def self.netzke_exposed_attributes
        preferences = self.component.flat_default_config
        # preferences = NetzkePreference.find_all_for_component(component.name)
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

      # somewhat sofisticated code to convert all NetzkePreferences for current component into a hash ("un-flatten")
      def attributes
        prefs = NetzkePreference.find_all_for_component(self.class.component.global_id)
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
        method_name = method_name.to_s
        method_name_without_equal_sign = method_name.sub(/=$/, '')
        NetzkePreference.component_name = self.class.component.global_id

        if method_name =~ /=$/
          current_value = self.class.component.flat_independent_config(method_name_without_equal_sign)
          
          begin
            new_value = ActiveSupport::JSON.decode(args.first) # TODO: provide feedback about this error
          rescue ActiveSupport::JSON::ParseError
            new_value = current_value
          end
          
          initial_value = self.class.component.flat_initial_config(method_name_without_equal_sign)
      
          new_value = nil if new_value == initial_value
          NetzkePreference[method_name_without_equal_sign] = new_value
        else
          res = self.class.component.flat_independent_config(method_name_without_equal_sign)
          res = ActiveSupport::JSON.encode(res) if res.is_a?(Array) || res.is_a?(Hash)
          res
        end
      end
  
    end
  end
end