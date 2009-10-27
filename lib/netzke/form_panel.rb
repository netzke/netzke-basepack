module Netzke
  # = FormPanel
  # 
  # Represents Ext.form.FormPanel
  # 
  # == Configuration
  # * <tt>:data_class_name</tt> - name of the ActiveRecord model that provides data to this GridPanel.
  # * <tt>:record</tt> - record to be displayd in the form. Takes precedence over <tt>:record_id</tt>
  # * <tt>:record_id</tt> - id of the record to be displayd in the form. Also see <tt>:record</tt>
  # 
  # In the <tt>:ext_config</tt> hash (see Netzke::Base) the following FormPanel specific options are available:
  # 
  # * <tt>:mode</tt> - when set to <tt>:config</tt>, FormPanel loads in configuration mode
  class FormPanel < Base
    include Netzke::FormPanelJs  # javascript (client-side)
    include Netzke::FormPanelApi # API (server-side)
    include Netzke::DataAccessor # some code shared between GridPanel, FormPanel, and other widgets that use database attributes

    # Class-level configuration with defaults
    def self.config
      set_default_config({
        :config_tool_available       => true,
        
        :default_config => {
          :persistent_config => true,
          :ext_config => {
            :tools => []
          },
        }
      })
    end
    
    def initial_config
      res = super
      res[:ext_config][:bbar] = default_bbar if res[:ext_config][:bbar].nil?
      res
    end

    def default_bbar
      %w{ apply }
    end
    
    # Extra javascripts
    def self.include_js
      [
        "#{File.dirname(__FILE__)}/form_panel_extras/javascripts/xcheckbox.js",
        Netzke::Base.config[:ext_location] + "/examples/ux/FileUploadField.js",
        "#{File.dirname(__FILE__)}/form_panel_extras/javascripts/netzkefileupload.js"
      ]
    end
    
    api :netzke_submit, :netzke_load, :get_combobox_options

    attr_accessor :record
    
    def initialize(*args)
      super
      apply_helpers
      @record = config[:record] || data_class && data_class.find_by_id(config[:record_id])
    end
    
    def data_class
      @data_class ||= config[:data_class_name] && config[:data_class_name].constantize
    end
    
    def configuration_widgets
      res = []
      
      res << {
        :name              => 'fields',
        :widget_class_name => "FieldsConfigurator",
        :active            => true,
        :widget            => self,
        :persistent_config => true
      }

      res << {
        :name               => 'general',
        :widget_class_name  => "PropertyEditor",
        :widget             => self,
        :ext_config         => {:title => false}
      }
      
      res
    end

    def actions
      {
        :apply => {:text => 'Apply'}
      }
    end
    
    def columns
      @columns ||= get_columns.convert_keys{|k| k.to_sym}
    end
    
    # parameters used to instantiate the JS object
    def js_config
      res = super
      res.merge!(:clmns => columns)
      res.merge!(:data_class_name => config[:data_class_name])
      res
    end
 
    # columns to be displayed by the FieldConfigurator (which is GridPanel-based)
    def self.config_columns
      [
        {:name => :name, :type => :string, :editor => :combobox, :width => 200},
        {:name => :hidden, :type => :boolean, :editor => :checkbox, :width => 40, :header => "Excl"},
        {:name => :disabled, :type => :boolean, :editor => :checkbox, :width => 40, :header => "Dis"},
        {:name => :xtype, :type => :string},
        {:name => :value, :type => :string},
        {:name => :field_label, :type => :string},
        {:name => :input_type, :type => :string}
      ]
    end
 
    def self.property_fields
      res = [
        {:name => :ext_config__title,               :type => :string},
        {:name => :ext_config__header,              :type => :boolean, :default => true},
        {:name => :ext_config__bbar,              :type => :json}
      ]
      
      res
    end
 
    # Normalized columns
    def normalized_columns
      @normalized_columns ||= normalize_columns(columns)
    end
    
 
    def get_columns
      if persistent_config_enabled?
        persistent_config['layout__columns'] ||= default_columns
        res = normalize_array_of_columns(persistent_config['layout__columns'])
      else
        res = default_columns
      end

      # merge values for each field if the record is specified
      @record && res.map! do |c|
        value = @record.send(normalize_column(c)[:name])
        value.nil? ? c : normalize_column(c).merge(:value => value)
      end

      res
    end
    
    XTYPE_MAP = {
      :integer => :numberfield,
      :boolean => :xcheckbox,
      :date => :datefield,
      :datetime => :xdatetime,
      :text => :textarea,
      :json => :jsonfield
      # :string => :textfield
    }
    
    def default_columns
      # columns specified in widget's config
      columns_from_config = config[:columns] && normalize_columns(config[:columns])
      
      if columns_from_config
        # reverse-merge each column hash from config with each column hash from exposed_attributes (columns from config have higher priority)
        for c in columns_from_config
          corresponding_exposed_column = predefined_columns.find{ |k| k[:name] == c[:name] }
          c.reverse_merge!(corresponding_exposed_column) if corresponding_exposed_column
        end
        columns_for_create = columns_from_config
      elsif predefined_columns
        # we didn't have columns configured in widget's config, so, use the columns from the data class
        columns_for_create = predefined_columns
      else
        raise ArgumentError, "No columns specified for widget '#{global_id}'"
      end
      
      columns_for_create.map! do |c|
        if data_class
          # Try to figure out the configuration from data class
          # detect :assoc__method
          if c[:name].to_s.index('__')
            assoc_name, method = c[:name].to_s.split('__').map(&:to_sym)
            if assoc = data_class.reflect_on_association(assoc_name)
              assoc_column = assoc.klass.columns_hash[method.to_s]
              assoc_method_type = assoc_column.try(:type)
              if assoc_method_type
                c[:xtype] ||= XTYPE_MAP[assoc_method_type] == :xcheckbox ? :xcheckbox : :combobox
              end
            end
          end
      
          # detect association column (e.g. :category_id)
          if assoc = data_class.reflect_on_all_associations.detect{|a| a.primary_key_name.to_sym == c[:name]}
            c[:xtype] ||= :combobox
            assoc_method = %w{name title label id}.detect{|m| (assoc.klass.instance_methods + assoc.klass.column_names).include?(m) } || assoc.klass.primary_key
            c[:name] = "#{assoc.name}__#{assoc_method}".to_sym
          end
          c[:hidden] = true if c[:name] == data_class.primary_key.to_sym && c[:hidden].nil? # hide ID column by default

        end
        
        # detect column type
        type = c[:type] || data_class && data_class.columns_hash[c[:name].to_s].try(:type) || :string
        c[:type] ||= type
        
        c[:xtype] ||= XTYPE_MAP[type] unless XTYPE_MAP[type].nil?

        # if the column is finally simply {:name => "something"}, cut it down to "something"
        c.reject{ |k,v| k == :name }.empty? ? c[:name] : c
      end
      
      columns_for_create
      
    end
     
    include Plugins::ConfigurationTool if config[:config_tool_available] # it will load ConfigurationPanel into a modal window      
  end
end