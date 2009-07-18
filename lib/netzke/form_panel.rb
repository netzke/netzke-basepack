module Netzke
  # == Configuration
  #   * <tt>:record</tt> - initial record to be displayd in the form
  class FormPanel < Base
    # Class-level configuration with defaults
    def self.config
      set_default_config({
        :config_tool_enabled       => false,
        :persistent_config_enabled => true
      })
    end

    include Netzke::FormPanelExtras::JsBuilder
    include Netzke::FormPanelExtras::Api
    include Netzke::DbFields # database field operations
    
    # extra javascripts
    js_include %w{ xcheckbox }.map{|js| "#{File.dirname(__FILE__)}/form_panel_extras/javascripts/#{js}.js"}
    
    api :submit, :load, :get_combo_box_options

    attr_accessor :record
    
    def self.widget_type
      :form
    end
    
    def initialize(*args)
      super
      @record = config[:record]
    end
    
    # default instance-level configuration
    def default_config
      {
        :ext_config => {
          :config_tool => self.class.config[:config_tool_enabled],
          :bbar => %w{ apply },
          :header => true
        },
        :persistent_config => self.class.config[:persistent_config_enabled]
      }
    end

    def configuration_widgets
      res = []
      
      res << {
        :name              => 'fields',
        :widget_class_name => "FieldsConfigurator",
        :active            => true,
        :widget            => self
      }

      res << {
        :name               => 'general',
        :widget_class_name  => "PropertyEditor",
        :widget             => self,
        :ext_config         => {:title => false}
      }
      
      res
    end

    def tools
      %w{ refresh }
    end
    
    def actions
      {
        :apply => {:text => 'Apply'}
      }
    end
    
    # def bbar
    #   persistent_config[:bottom_bar] ||= config[:bbar] == false ? nil : config[:bbar] || %w{ apply }
    # end
    
    def columns
      @columns ||= get_columns.convert_keys{|k| k.to_sym}
    end
    
    # parameters used to instantiate the JS object
    def js_config
      res = super
      if @record && false
        # add the values
        res.merge!(:columns => columns.map{ |c| c.merge(:value => @record.send(c[:name]))})
      else
        res.merge!(:columns => columns)
      end
      res.merge!(:data_class_name => config[:data_class_name])
      # res.merge!(:record_data => @record.to_array(columns)) if @record
      res
    end
 
    protected
    
    def get_columns
      res = persistent_config['layout__columns'] ||= default_db_fields.map{ |r| r.reject{ |k,v| k == :id } }
      
      # merge values for each field if the record is known
      if @record
        res.each{ |c| c.merge!(:value => @record.send(c.name)) }
      end
      res
    end
      
    
    # def available_permissions
    #   %w{ read update }
    # end
    
    include ConfigurationTool # it will load aggregation with name :properties into a modal window
      
  end
end