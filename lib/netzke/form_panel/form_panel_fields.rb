module Netzke
  class FormPanel < Base
    module FormPanelFields
      module ClassMethods
        # Columns to be displayed by the FieldConfigurator, "meta-columns". Each corresponds to a configuration
        # option for each field in the form.
        def meta_columns
          [
            {:name => "included", :attr_type => :boolean, :width => 40, :header => "Incl", :default_value => true},
            {:name => "name", :attr_type => :string, :editor => :combobox, :width => 200},
            {:name => "label", :attr_type => :string, :header => "Label"},
            {:name => "default_value", :attr_type => :string}
          ]
        end
        
      end
      
      module InstanceMethods
        def fields
          @fields ||= begin
            flds = load_fields
            flds ||= initial_fields
            
            flds.map! do |c|
              value = record.send(c[:name])
              value.nil? ? c : c.merge(:value => value)
            end if record
            
            flds
          end
        end

        def default_fields
          @default_fields ||= load_model_level_attrs || (data_class && data_class.netzke_attributes) || []
        end

        def initial_fields(only_included = true)
          ::ActiveSupport::Deprecation.warn("The :columns option for FormPanel is deprecated. Use :fields instead", caller) if config[:columns]
          
          # Normalize here, as from the config we can get symbols (names) instead of hashes
          fields_from_config = (config[:columns] || config[:fields]) && normalize_attr_config(config[:columns] || config[:fields])

          if fields_from_config
            # reverse-merge each column hash from config with each column hash from exposed_attributes (fields from config have higher priority)
            for c in fields_from_config
              corresponding_exposed_column = default_fields.find{ |k| k[:name] == c[:name] }
              c.reverse_merge!(corresponding_exposed_column) if corresponding_exposed_column
            end
            fields_for_create = fields_from_config
          elsif default_fields
            # we didn't have fields configured in widget's config, so, use the fields from the data class
            fields_for_create = default_fields
          else
            raise ArgumentError, "No fields specified for widget '#{global_id}'"
          end
          
          fields_for_create.reject!{ |c| c[:included] == false }
          
          fields_for_create.map! do |c|
            if data_class

              detect_association_with_method(c)
              
              # detect association column (e.g. :category_id)
              if assoc = data_class.reflect_on_all_associations.detect{|a| a.primary_key_name == c[:name]}
                c[:xtype] ||= xtype_for_association
                assoc_method = %w{name title label id}.detect{|m| (assoc.klass.instance_methods + assoc.klass.column_names).include?(m) } || assoc.klass.primary_key
                c[:name] = "#{assoc.name}__#{assoc_method}"
              end

              c[:hidden] = true if c[:name] == data_class.primary_key && c[:hidden].nil? # hide ID column by default
            end

            set_default_field_label(c)
            
            c[:xtype] ||= xtype_for_attr_type(c[:attr_type]) # unless xtype_map[type].nil?
            c
          end

          fields_for_create

        end
      end
      
      private
        # Stores modified fields in persistent storage (not used in forms, as we can't modify them on the fly, only via FieldsConfigurator)
        # def save_fields!
        #   NetzkeFieldList.update_list_for_current_authority(global_id, fields, data_class.name)
        # end
      
        def load_fields
          NetzkeFieldList.read_list(global_id) if persistent_config_enabled?
        end
        
        def load_model_level_attrs
          NetzkeModelAttrList.read_list(data_class.name) if data_class
        end
        
        def set_default_field_label(c)
          c[:label] ||= c[:name].humanize
        end
      
        def attr_type_to_xtype_map
          {
            :integer => :numberfield,
            :boolean => :xcheckbox,
            :date => :datefield,
            :datetime => :xdatetime,
            :text => :textarea,
            :json => :jsonfield
            # :string => :textfield
          }
        end
        
        def xtype_for_attr_type(type)
          attr_type_to_xtype_map[type]
        end
        
        def xtype_for_association
          :combobox
        end
        
        def detect_association_with_method(c)
          if c[:name].to_s.index('__')
            assoc_name, method = c[:name].split('__').map(&:to_sym)
            if assoc = data_class.reflect_on_association(assoc_name)
              assoc_column = assoc.klass.columns_hash[method.to_s]
              assoc_method_type = assoc_column.try(:type)
              if assoc_method_type
                c[:xtype] ||= assoc_method_type == :boolean ? xtype_for_attr_type(assoc_method_type) : :combobox
              end
            end
          end
          
        end

      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods

        receiver.class_eval do
          alias :initial_columns :initial_fields
        end
      end
    end
  end
end