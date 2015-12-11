module Netzke
  module Basepack
    # Because Form allows for arbitrary layout of fields, we need to have all fields configured in one place (the +fields+ method), and then have references to those fields from +items+.
    module Fields
      extend ActiveSupport::Concern

      # Items with normalized fields (i.e. containing all the necessary attributes needed by Ext.form.Form to render a field)
      def items
        prepend_primary_key(config.items) || model_adapter.model_attributes
      end

      # Hash of fully configured fields, that are referenced in the items. E.g.:
      #   {
      #     role__name: {xtype: 'netzkeremotecombo', disabled: true, value: "admin"},
      #     created_at: {xtype: 'datetime', disabled: true, value: "2010-10-10 10:10"}
      #   }
      def fields
        @_fields ||= fields_from_items.tap do |flds|
          # add primary key field if not present
          primary_key = model_adapter.primary_key
          flds[primary_key.to_sym] ||= {name: primary_key}
        end
      end

      # Hash of normalized field configs extracted from :items, e.g.:
      #
      #     {
      #       role__name: {xtype: "netzkeremotecombo"},
      #       password: {xtype: "passwordfield"}
      #     }
      def fields_from_items
        @fields_from_items || (normalize_config || true) && @fields_from_items
      end

    protected

      # An override. This is where we expand our basic field config with all the defaults
      def extend_item(field)
        item = super
        is_field_config?(item) ? extend_field(item) : item
      end

      def extend_field(field)
        Netzke::Basepack::FieldConfig.new(field, model_adapter).tap do |c|
          # not binding to a model attribute
          return c if c.bind == false

          # merge in attribute
          c.merge_attribute(attribute_overrides[c.name.to_sym] || {})

          return nil if c.excluded

          @fields_from_items[c.name.to_sym] = c

          c.set_defaults
        end
      end

      private

      def prepend_primary_key(items)
        items && items.tap do |items|
          items.insert(0, model_adapter.primary_key.to_sym) if !includes_primary_key?(items)
        end
      end

      def includes_primary_key?(items)
        !!items.detect do |item|
          (item.is_a?(Hash) ? item[:name] : item.to_s) == model_adapter.primary_key
        end
      end

      def is_field_config?(item)
        item.is_a?(Symbol) || (item.is_a?(Hash) && item[:name]) # && !is_component_config?(item)
      end
    end
  end
end
