require "netzke/property_editor/helper_model"

module Netzke
  class PropertyEditor < FormPanel
    
    def initialize(*args)
      super
      @widget = @passed_config[:widget]
    end
    
    def default_bbar
      %w{ restore_defaults }
    end

    def actions
      {:restore_defaults => {:text => "Restore defaults"}}
    end

    def get_columns
      fields = @widget.class.property_fields

      for f in fields
        f[:value] = @widget.flat_config(f[:name]).nil? ? f[:default] : @widget.flat_config(f[:name])
        f[:xtype] = xtype_map[f[:type]]
        f[:field_label] = f[:name].to_s.gsub("__", "/").humanize
      end
      
      fields
    end
    
    def self.js_extend_properties
      {
        :label_width => 200,
        
        # Disable the 'gear' tool for now
        :on_gear => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.feedback("You can't configure property editor (yet)");
          }
        END_OF_JAVASCRIPT
        
        :on_restore_defaults => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.restoreDefaults();
          }
        END_OF_JAVASCRIPT
        
        :get_commit_data => <<-END_OF_JAVASCRIPT.l
          function(){
            if (!this.getForm().isValid()) {this.getForm().reset()}; // if some fields are invalid, don't send anything
            var values = this.getForm().getValues();
            for (var k in values) {
              if (values[k] == "") {values[k] = null}
            }
            return values;
          }
        END_OF_JAVASCRIPT
      }
    end
    
    api :restore_defaults
    def restore_defaults(params)
      values = []
      columns.each do |c|
        init_config = @widget.flat_initial_config.detect{ |ic| ic[:name] == c[:name] }
        
        if init_config.nil?
          property_fields ||= @widget.class.property_fields
          values << property_fields.detect{ |f| f[:name] == c[:name] }[:default]
        else
          values << init_config[:value]
        end
        
      end
      {:set_form_values => values}
    end
    
    def commit(data)
      fields = @widget.class.property_fields
      data.each_pair do |property, value|
        field = fields.detect{ |f| f[:name] == property.to_sym }
        default = @widget.flat_initial_config(property).nil? ? field[:default] : @widget.flat_initial_config(property)

        new_value = normalize_form_value(value, field)

       # Only store the value in persistent config when it's different from the default one
        if field[:type] == :boolean
          # handle boolean type separately
          @widget.persistent_config[property] = new_value ^ default ? new_value : nil
        else 
          @widget.persistent_config[property] = default == new_value ? nil : new_value
        end
      end
      {}
    end
    
    def normalize_form_value(value, field)
      case field[:type]
      when :boolean
        value.to_b
      when :json
        ActiveSupport::JSON.decode(value) # no need to check for exceptions, as the value has been validated in browser
      when :integer
        value.to_i
      else
        value # TODO: support other types like :date and :datetime
      end
    end
    
  end
end