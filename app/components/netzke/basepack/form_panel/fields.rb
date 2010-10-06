module Netzke
  module Basepack
    class FormPanel < Netzke::Base
      module Fields
        extend ActiveSupport::Concern
      
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
      
        # Fully configured field array passed to the JS side (see js_config)
        def fields
          @fields ||= begin
            flds = load_persistent_fields
            reverse_merge_equally_named_fields(flds, initial_fields) if flds
            flds ||= initial_fields

            if record
              record_data = record.to_array(flds)
              flds.each_with_index do |c, i|
                c.merge!(:value => record_data[i]) if !record_data[i].nil?
              end
            end
          
            flds
          end
        end

        # Fields used when no :items are provided in the configuration
        def default_fields
          @_default_fields ||= load_model_level_attrs || (data_class && data_class.netzke_attributes) || []
        end

        # Array of normalized field configs extracted from :items
        def fields_from_config
          @_fields_from_config ||= config[:items] && normalize_items_and_collect_fields(config[:items])
        end

        # Full 
        def initial_fields(only_included = true)
          # Normalize here, as from the config we can get symbols (names) instead of hashes
          # fields_from_config = (config[:columns] || config[:fields]) && normalize_attrs(config[:columns] || config[:fields])

          if fields_from_config
            # automatically add a field that reflects the primary key, unless specified in the config; it should be added to the end
            fields_from_config.push({:name => data_class.primary_key}) if data_class && !fields_from_config.any?{ |c| c[:name] == data_class.primary_key }
          
            # reverse-merge each column hash from config with each column hash from exposed_attributes (fields from config have higher priority)
            for c in fields_from_config
              corresponding_exposed_column = default_fields.find{ |k| k[:name] == c[:name] }
              c.reverse_merge!(corresponding_exposed_column) if corresponding_exposed_column
            end
            fields_for_create = fields_from_config
          elsif default_fields
            # we didn't have fields configured in component's config, so, use the fields from the data class
            fields_for_create = default_fields
          else
            raise ArgumentError, "No fields specified for component '#{global_id}'"
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
      
        private
          # Stores modified fields in persistent storage (not used in forms, as we can't modify them on the fly, only via FieldsConfigurator)
          # def save_fields!
          #   NetzkeFieldList.update_list_for_current_authority(global_id, fields, data_class.name)
          # end
      
          def load_persistent_fields
            # NetzkeFieldList.read_list(global_id) if persistent_config_enabled?
          end
        
          def load_model_level_attrs
            # NetzkeModelAttrList.read_list(data_class.name) if persistent_config_enabled? && data_class
          end
        
          def set_default_field_label(c)
            c[:label] ||= c[:name].humanize.sub(/\s+/, " ") # multiple spaces get replaced with one
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

          # Receives 2 arrays of columns. Merges the missing config from the +source+ into +dest+, matching columns by name
          def reverse_merge_equally_named_fields(dest, source)
            dest.each{ |dc| dc.reverse_merge!(source.detect{ |sc| sc[:name] == dc[:name] } || {}) }
          end

          # Normalize config[:items] and extract fields out of them
          def process_items_config
            super
            normalize_items_and_collect_fields(@js_items) if @js_items
          end
        
          # Recursively extracts fields configuration from :items
          def normalize_items_and_collect_fields(items)
            items.each_with_index.inject([]) do |r, (item, i)|
              items[i] = item = normalize_item(item)
              if is_a_field?(item)
                r + [item]
              elsif item.is_a?(Hash)
                item[:items].is_a?(Array) ? r + normalize_items_and_collect_fields(item[:items]) : r
              end
            end
          end

          def is_a_field?(item)
            item[:name] && !item[:class_name] # TODO: delegate it to Base#is_a_component? method
          end

          def normalize_item(item)
            item.is_a?(String) || item.is_a?(Symbol) ? {:name => item.to_s} : item.is_a?(Hash) && item[:name] ? item.merge(:name => item[:name].to_s) : item
          end
        
      end
    end
  end
end