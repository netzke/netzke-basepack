# require "netzke/form_panel/form_panel_js"
# require "netzke/form_panel/form_panel_api"
# require "netzke/form_panel/form_panel_fields"
# require "netzke/plugins/configuration_tool"
# require "netzke/data_accessor"

module Netzke::Widget
  # = FormPanel
  # 
  # Represents Ext.form.FormPanel
  # 
  # == Configuration
  # * <tt>:model</tt> - name of the ActiveRecord model that provides data to this GridPanel.
  # * <tt>:record</tt> - record to be displayd in the form. Takes precedence over <tt>:record_id</tt>
  # * <tt>:record_id</tt> - id of the record to be displayd in the form. Also see <tt>:record</tt>
  # 
  # In the <tt>:ext_config</tt> hash (see Netzke::Base) the following FormPanel specific options are available:
  # 
  # * <tt>:mode</tt> - when set to <tt>:config</tt>, FormPanel loads in configuration mode
  class FormPanel < Base
    include FormPanelJs  # javascript (client-side)
    include FormPanelApi # API (server-side)
    include FormPanelFields # fields
    include Netzke::DataAccessor # some code shared between GridPanel, FormPanel, and other widgets that use database attributes

    # Class-level configuration with defaults
    def self.config
      set_default_config({
        :config_tool_available       => true,
        
        :default_config => {
          :persistent_config => true,
          :tools => []
        }
      })
    end
    
    def initial_config
      res = super
      res[:bbar] = default_bbar if res[:bbar].nil?
      res
    end

    def default_bbar
      [:apply.ext_action]
    end
    
    # Extra javascripts
    def self.include_js
      [
        # "#{File.dirname(__FILE__)}/form_panel/javascripts/xcheckbox.js",
        # Netzke::Widget::Base.config[:ext_location] + "/examples/ux/fileuploadfield/FileUploadField.js",
        # "#{File.dirname(__FILE__)}/form_panel/javascripts/netzkefileupload.js"
      ]
    end
    
    api :netzke_submit, :netzke_load, :get_combobox_options

    attr_accessor :record
    
    def initialize(*args)
      super
      apply_helpers
    end
    
    # Model class
    # (We can't memoize this method because at some point we extend it, e.g. in Netzke::DataAccessor)
    def data_class
      @data_class ||= begin
        klass = "Netzke::ModelExtensions::#{config[:model]}For#{short_widget_class_name}".constantize rescue nil
        klass || original_data_class
      end
    end
    
    # Model class before model extensions are taken into account
    def original_data_class
      @original_data_class ||= begin
        ::ActiveSupport::Deprecation.warn("data_class_name option is deprecated. Use model instead", caller) if config[:data_class_name]
        model_name = config[:model] || config[:data_class_name]
        model_name && model_name.constantize
      end
    end
    
    def record
      @record ||= config[:record] || config[:record_id] && data_class && data_class.find(:first, :conditions  => {data_class.primary_key => config[:record_id]})
    end
    
    def configuration_widgets
      res = []
      
      res << {
        :name              => 'fields',
        :class_name => "FieldsConfigurator",
        :active            => true,
        :owner             => self,
        :persistent_config => true
      }

      res << {
        :name               => 'general',
        :class_name  => "PropertyEditor",
        :widget             => self,
        :title => false
      }
      
      res
    end

    def actions
      actions = {
        :apply => {:text => 'Apply'}
      }
      
      if Netzke::Widget::Base.config[:with_icons]
        icons_uri = Netzke::Widget::Base.config[:icons_uri]
        actions.deep_merge!(
          :apply => {:icon => icons_uri + "tick.png"}
        )
      end
      
      actions
    end
    
    def self.property_fields
      res = [
        # {:name => "ext_config__title",               :attr_type => :string},
        # {:name => "ext_config__header",              :attr_type => :boolean, :default => true},
        # {:name => "ext_config__bbar",              :attr_type => :json}
      ]
      
      res
    end
 
    private
      
      def self.server_side_config_options
        [:record]
      end
 
    include Netzke::Plugins::ConfigurationTool if config[:config_tool_available] # it will load ConfigurationPanel into a modal window      
  end
end