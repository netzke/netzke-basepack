module Netzke
  # == Configuration
  #   * <tt>:record</tt> - initial record to be displayd in the form
  class FormPanel < Base
    include Netzke::FormPanelJs  # javascript (client-side)
    include Netzke::FormPanelApi # API (server-side)

    # Class-level configuration with defaults
    def self.config
      set_default_config({
        :config_tool_available       => true,
        
        :default_config => {
          :ext_config => {
            :bbar => %w{ apply },
            :tools => %w{ refresh }
          },
          :persistent_config => false
        }
      })
    end
    
    # Extra javascripts
    def self.include_js
      [
        "#{File.dirname(__FILE__)}/form_panel_extras/javascripts/xcheckbox.js"
      ]
    end
    
    api :submit, :load, :get_combobox_options

    attr_accessor :record
    
    def initialize(*args)
      super
      @record = config[:record]
    end
    
    def data_class
      # @data_class ||= config[:data_class_name].nil? ? raise(ArgumentError, "No data_class_name specified for widget #{id_name}") : config[:data_class_name].constantize
      @data_class ||= config[:data_class_name] && config[:data_class_name].constantize
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
    
    def columns
      @columns ||= get_columns.convert_keys{|k| k.to_sym}
    end
    
    def normalized_columns
      @normalized_columns ||= normalize_fields(columns)
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
        {:name => :xtype, :type => :string},
        {:name => :value, :type => :string},
        {:name => :field_label, :type => :string}
      ]
    end
 
    protected
    def get_columns
      if config[:persistent_config]
        persistent_config['layout__columns'] ||= default_fields
        res = normalize_array_of_fields(persistent_config['layout__columns'])
      else
        res = default_fields
      end

      # merge values for each field if the record is specified
      @record && res.map! do |c|
        value = @record.send(normalize_field(c)[:name])
        value.nil? ? c : normalize_field(c).merge(:value => value)
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
    
    def normalize_array_of_fields(arry)
      arry.map do |f| 
        if f.is_a?(Hash)
          f.symbolize_keys
        else
          f.to_sym
        end
      end
    end
    
    def normalize_fields(items)
      items.map{|c| normalize_field(c)}
    end
    
    def normalize_field(field)
      field.is_a?(Symbol) ? {:name => field} : field
    end
    
    def default_fields
      # columns exposed from the data class
      exposed_columns = normalize_fields(data_class.netzke_exposed_attributes) if data_class

      # columns specified in widget's config
      columns_from_config = config[:columns] && normalize_fields(config[:columns])
      
      if columns_from_config
        # reverse-merge each column hash from config with each column hash from exposed_attributes (columns from config have higher priority)
        if exposed_columns
          for c in columns_from_config
            corresponding_exposed_column = exposed_columns.find{ |k| k[:name] == c[:name] }
            c.reverse_merge!(corresponding_exposed_column) if corresponding_exposed_column
          end
        end
        columns_for_create = columns_from_config
      elsif exposed_columns
        # we didn't have columns configured in widget's config, so, use the columns from the data class
        columns_for_create = exposed_columns
      else
        raise ArgumentError, "No columns specified for widget '#{id_name}'"
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
        
        c[:xtype] ||= XTYPE_MAP[type] unless XTYPE_MAP[type].nil?

        # if the column is finally simply {:name => "something"}, cut it down to "something"
        c.reject{ |k,v| k == :name }.empty? ? c[:name] : c
      end
      
      columns_for_create
      
    end
     
    
    # def available_permissions
    #   %w{ read update }
    # end
    
    include ConfigurationTool if config[:config_tool_available] # it will load ConfigurationPanel into a modal window      
  end
end