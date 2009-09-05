module Netzke
  class PropertyEditor < FormPanel
    
    def initialize(*args)
      super
      @widget = @passed_config[:widget]
    end
    
    def independent_config
      res = super
      res[:ext_config][:bbar] = %w{ restore_defaults }
      res
    end

    def actions
      {:restore_defaults => {:text => "Restore defaults"}}
    end

    def get_columns
      fields = @widget.class.property_fields

      for f in fields
        f[:value] = @widget.flat_config(f[:name]).nil? ? f[:default] : @widget.flat_config(f[:name])
        f[:xtype] = XTYPE_MAP[f[:type]]
        f[:field_label] = f[:name].to_s.gsub("__", "/").humanize
      end
      
      fields
    end
    
    def self.js_extend_properties
      {
        :label_width => 200,
        
        # Disable the 'gear' tool for now
        :gear => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.feedback("You can't configure property editor (yet)");
          }
        END_OF_JAVASCRIPT
        
        :restore_defaults => <<-END_OF_JAVASCRIPT.l,
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
        # default = @widget.config[property].nil? ? field[:default] : @widget.config[property]
        default = @widget.flat_initial_config(property).nil? ? field[:default] : @widget.flat_initial_config(property)
        # Only store the value in persistent config when it's different from the default one
        if field[:type] == :boolean
          # handle boolean type separately
          value = value.to_b
          @widget.persistent_config[property] = value ^ default ? value : nil
        else 
          if field[:type] == :json
            value = ActiveSupport::JSON.decode(value)
          end

          # Empty string means "null" for now...
          # value = nil if value.blank?
          # logger.debug "!!! value: #{value.inspect}\n"
          
          @widget.persistent_config[property] = default == value ? nil : value
        end
      end
      {}
    end
    
  end
end