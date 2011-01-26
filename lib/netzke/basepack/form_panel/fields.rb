module Netzke
  module Basepack
    class FormPanel < Netzke::Base
      # Because FormPanel allows for arbitrary layout of fields, we need to have all fields configured in one place (the +fields+ method), and then have references to those fields from +items+.
      module Fields
        extend ActiveSupport::Concern

        # Items with normalized fields (i.e. containing all the necessary attributes needed by Ext.form.FormPanel to render a field)
        def items
          @form_panel_items ||= begin
            res = normalize_fields(super || data_class && data_class.netzke_attributes || []) # netzke_attributes as default items
            # if primary key isn't there, insert it as first
            if data_class && !res.detect{ |f| f[:name] == data_class.primary_key}
              primary_key_item = normalize_field(data_class.primary_key.to_sym)
              @fields_from_config[data_class.primary_key.to_sym] = primary_key_item
              res.insert(0, primary_key_item)
            end

            res
          end
        end

        # Hash of fully configured fields, that are referenced in the items. E.g.:
        #   {
        #     :role__name => {:xtype => 'netzkeremotecombo', :disabled => true, :value => "admin"},
        #     :created_at => {:xtype => 'datetime', :disabled => true, :value => "2010-10-10 10:10"}
        #   }
        def fields
          @fields ||= begin
            if static_layout?
              # extract incomplete field configs from +config+
              flds = fields_from_config
              # and merged them with fields from the model
              deep_merge_existing_fields(flds, fields_from_model) if data_class
            else
              # extract flds configs from the model
              flds = fields_from_model
            end
            flds
          end
        end

        # The array of fields as specified on the model level (using +netzke_attribute+ and alike)
        def fields_array_from_model
          data_class && data_class.netzke_attributes
        end

        # Hash of fields as specified on the model level
        def fields_from_model
          @fields_from_model ||= fields_array_from_model && fields_array_from_model.inject({}){ |hsh, f| hsh.merge(f[:name].to_sym => f) }
        end

        # Hash of normalized field configs extracted from :items, e.g.:
        #
        #     {:role__name => {:xtype => "netzkeremotecombo"}, :password => {:xtype => "passwordfield"}}
        def fields_from_config
          items if @fields_from_config.nil? # by calling +items+ we initiate building of @fields_from_config
          @fields_from_config ||= {}
        end

        module ClassMethods
          # Columns to be displayed by the FieldConfigurator, "meta-columns". Each corresponds to a configuration
          # option for each field in the form.
          def meta_columns
            [
              {:name => "included", :attr_type => :boolean, :width => 40, :header => "Incl", :default_value => true},
              {:name => "name", :attr_type => :string, :editor => :netzkeremotecombo, :width => 200},
              {:name => "label", :attr_type => :string, :header => "Label"},
              {:name => "default_value", :attr_type => :string}
            ]
          end
        end

        private
          def load_persistent_fields
            # NetzkeFieldList.read_list(global_id) if persistent_config_enabled?
          end

          def load_model_level_attrs
            # NetzkeModelAttrList.read_list(data_class.name) if persistent_config_enabled? && data_class
          end

          # This is where we expand our basic field config with all the defaults
          def normalize_field(field)
            # field can only be a string, a symbol, or a hash
            if field.is_a?(Hash)
              field = field.dup # we don't want to modify original hash
              return field if field[:no_binding] # stop here if no normalization is needed
              field[:name] = field[:name].to_s if field[:name] # all names should be strings
            else
              field = {:name => field.to_s}
            end

            field_from_model = fields_from_model && fields_from_model[field[:name].to_sym]

            field_from_model && field.merge!(field_from_model)

            detect_association_with_method(field) # xtype for an association field
            set_default_field_label(field)
            set_default_field_xtype(field) if field[:xtype].nil?
            # set_default_field_value(field) if self.record
            set_default_read_only(field)

            field[:display_mode] = config[:display_mode] if config[:display_mode]

            # provide our special combobox with our id
            field[:parent_id] = self.global_id if field[:xtype] == :netzkeremotecombo

            field[:hidden] = field[:hide_label] = true if field[:hidden].nil? && primary_key_attr?(field)

            # checkbox setup
            field[:checked] = field[:value] if field[:attr_type] == :boolean
            field[:input_value] = true if field[:attr_type] == :boolean

            field
          end

          # Sets the proper xtype of an asociation field
          def detect_association_with_method(c)
            if c[:name].index('__')
              assoc_name, method = c[:name].split('__').map(&:to_sym)
              if method && assoc = data_class.reflect_on_association(assoc_name)
                assoc_column = assoc.klass.columns_hash[method.to_s]
                assoc_method_type = assoc_column.try(:type)
                if c[:nested_attribute]
                  c[:xtype] ||= xtype_for_attr_type(assoc_method_type)
                else
                  c[:xtype] ||= assoc_method_type == :boolean ? xtype_for_attr_type(assoc_method_type) : xtype_for_association
                end
              end
            end
          end

          # RECURSIVELY extracts fields configuration from :items
          def normalize_fields(items)
            @fields_from_config ||= {}
            items.map do |item|
              # at this moment, item is a hash or a symbol
              if is_field_config?(item)
                item = normalize_field(item)
                @fields_from_config[item[:name].to_sym] = item
                item #.reject{ |k,v| k == :name } # do we really need to remove the :name key?
              elsif item.is_a?(Hash)
                item = item.dup # we don't want to modify original hash
                item[:items].is_a?(Array) ? item.merge(:items => normalize_fields(item[:items])) : item
              else
                item
              end
            end
          end

          def is_field_config?(item)
            item.is_a?(String) || item.is_a?(Symbol) || item[:name] # && !is_component_config?(item)
          end

          def set_default_field_label(c)
            # multiple spaces (in case of association attrs) get replaced with one
            c[:field_label] ||= data_class ? data_class.human_attribute_name(c[:name]) : c[:name].humanize
            c[:field_label].gsub!(/\s+/, " ")
          end

          # def set_default_field_value(field)
          #   value = record.value_for_attribute(field)
          #   field[:value] ||= value unless value.nil?
          # end

          # Deeply merges only those key/values at the top level that are already there
          def deep_merge_existing_fields(dest, src)
            dest.each_pair do |k,v|
              v.deep_merge!(src[k] || {})
            end
          end

          def set_default_field_xtype(field)
            field[:xtype] = xtype_for_attr_type(field[:attr_type]) unless xtype_for_attr_type(field[:attr_type]).nil?
          end

          def set_default_read_only(field)
            enabled_if = !data_class || data_class.column_names.include?(field[:name])
            enabled_if ||= data_class.instance_methods.map(&:to_s).include?("#{field[:name]}=")
            enabled_if ||= record && record.respond_to?("#{field[:name]}=")
            enabled_if ||= association_attr?(field[:name])

            field[:read_only] = !enabled_if if field[:read_only].nil?
          end

          def attr_type_to_xtype_map
            {
              :integer => :numberfield,
              :boolean => :checkbox,
              :date => :datefield,
              :datetime => :xdatetime,
              :text => :textarea,
              :json => :jsonfield,
              :string => :textfield
            }
          end

          def xtype_for_attr_type(type)
            attr_type_to_xtype_map[type] || :textfield
          end

          def xtype_for_association
            :netzkeremotecombo
          end

          # Are we provided with a static field layout?
          def static_layout?
            !!config[:items]
          end

      end
    end
  end
end
