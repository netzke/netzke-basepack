module Netzke
  module Basepack
    module FormLib
      # Because Form allows for arbitrary layout of fields, we need to have all fields configured in one place (the +fields+ method), and then have references to those fields from +items+.
      module Fields
        extend ActiveSupport::Concern

        # Items with normalized fields (i.e. containing all the necessary attributes needed by Ext.form.Form to render a field)
        def items
          config.items || data_class && data_adapter.model_attributes || []
        end

        # Hash of fully configured fields, that are referenced in the items. E.g.:
        #   {
        #     :role__name => {:xtype => 'netzkeremotecombo', :disabled => true, :value => "admin"},
        #     :created_at => {:xtype => 'datetime', :disabled => true, :value => "2010-10-10 10:10"}
        #   }
        def fields
          @fields ||= begin
            # extract incomplete field configs from +config+
            flds = fields_from_config

            primary_key = data_adapter.primary_key_name
            flds[primary_key.to_sym] ||= {name: primary_key}

            # and merged them with fields from the model
            deep_merge_existing_fields(flds, fields_from_model) if data_adapter
            flds
          end
        end

        # The array of fields as specified on the model level (using +netzke_attribute+ and alike)
        def fields_array_from_model
          data_adapter && data_adapter.model_attributes
        end

        # Hash of fields as specified on the model level
        def fields_from_model
          @fields_from_model ||= fields_array_from_model && fields_array_from_model.inject({}){ |hsh, f| hsh.merge(f[:name].to_sym => f) }
        end

        # Hash of normalized field configs extracted from :items, e.g.:
        #
        #     {:role__name => {:xtype => "netzkeremotecombo"}, :password => {:xtype => "passwordfield"}}
        def fields_from_config
          @fields_from_config || (normalize_config || true) && @fields_from_config
        end

      protected

        # This is where we expand our basic field config with all the defaults
        def extend_item(field)
          field = super

          if is_field_config?(field)
            # field can only be a string, a symbol, or a hash
            if field.is_a?(Hash)
              field = field.dup # we don't want to modify original hash
              return field if field[:no_binding] # stop here if no normalization is needed
              field[:name] = field[:name].to_s if field[:name] # all names should be strings
            else
              field = {:name => field.to_s}
            end

            # right place?
            @fields_from_config[field[:name].to_sym] = field

            field_from_model = fields_from_model && fields_from_model[field[:name].to_sym]

            field_from_model && field.merge!(field_from_model)

            detect_association_with_method(field) # xtype for an association field
            set_default_field_label(field)
            set_default_field_xtype(field) if field[:xtype].nil?
            set_default_read_only(field)

            # provide our special combobox with our id
            field[:parent_id] = self.js_id if field[:xtype] == :netzkeremotecombo

            field[:hidden] = field[:hide_label] = true if field[:hidden].nil? && data_adapter.try(:primary_key_attr?, field)

            # checkbox setup
            if field[:attr_type] == :boolean
              field[:checked] = field[:value]
              field[:unchecked_value] = false
              field[:input_value] = true if field[:attr_type] == :boolean
            end

            # date field format
            if field[:attr_type] = :date
              field[:submit_format] = "Y-m-d"
              field[:format] ||= "Y-m-d"
            end
          end

          field
        end

        # Sets the proper xtype of an asociation field
        def detect_association_with_method(c)
          if c[:name].index('__')
            assoc_name, method = c[:name].split('__').map(&:to_sym)
            assoc_method_type = data_adapter.get_assoc_property_type(assoc_name, method)
            if c[:nested_attribute]
              c[:xtype] ||= xtype_for_attr_type(assoc_method_type)
            else
              c[:xtype] ||= assoc_method_type == :boolean ? xtype_for_attr_type(assoc_method_type) : xtype_for_association
            end
          end
        end

        def is_field_config?(item)
          item.is_a?(Symbol) || (item.is_a?(Hash) && item[:name]) # && !is_component_config?(item)
        end

        # Deeply merges only those key/values at the top level that are already there
        def deep_merge_existing_fields(dest, src)
          dest.each_pair do |k,v|
            v.deep_merge!(src[k] || {})
          end
        end

        def set_default_field_label(c)
          # multiple spaces (in case of association attrs) get replaced with one
          c[:field_label] ||= data_class ? data_class.human_attribute_name(c[:name]) : c[:name].humanize
          c[:field_label].gsub!(/\s+/, " ")
        end

        def set_default_field_xtype(field)
          field[:xtype] = xtype_for_attr_type(field[:attr_type]) unless xtype_for_attr_type(field[:attr_type]).nil?
        end

        def set_default_read_only(field)
          enabled_if = !data_adapter || data_adapter.attribute_names.include?(field[:name])
          enabled_if ||= data_class.instance_methods.map(&:to_s).include?("#{field[:name]}=")
          enabled_if ||= record && record.respond_to?("#{field[:name]}=")
          enabled_if ||= association_attr?(field[:name])

          field[:read_only] = !enabled_if if field[:read_only].nil?
        end

        def attr_type_to_xtype_map
          {
            :integer => :numberfield,
            :boolean => config[:multi_edit] ? :tricheckbox : :checkboxfield,
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
      end
    end
  end
end
