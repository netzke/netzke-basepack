module Netzke
  module Basepack
    # Takes care of automatic field configuration in {Form::Base}
    class FieldConfig < AttrConfig
      def merge_attribute(attr)
        self.merge!(attr)

        self.field_label = self.delete(:label) if self.has_key?(:label)

        self.merge!(delete(:field_config)) if self.has_key?(:field_config)

        self.delete(:column_config) if self.has_key?(:column_config)
      end

      def set_defaults
        super

        self.type ||= @model_adapter.attr_type(name)

        set_xtype if xtype.nil?

        self.field_label ||= @model_adapter.human_attribute_name(name).gsub(/\s+/, " ")

        self.hidden = true if hidden.nil? && primary?
        self.hide_label = hidden if hide_label.nil?

        case type
        when :boolean
          configure_checkbox
        when :date
          configure_date_field
        end
      end

    private

      def set_xtype
        if association?
          set_xtype_for_association
        else
          self.xtype = xtype_for_type(type)
        end
      end

      def set_xtype_for_association
        assoc_name, method = name.split('__').map(&:to_sym)
        assoc_method_type = @model_adapter.get_assoc_property_type(assoc_name, method)
        if nested_attribute
          self.xtype = xtype_for_type(assoc_method_type)
        else
          self.xtype = assoc_method_type == :boolean ? xtype_for_type(assoc_method_type) : :netzkeremotecombo
        end
      end

      def xtype_for_type(type)
        { integer:    :numberfield,
          boolean:    :checkboxfield,
          date:       :datefield,
          datetime:   :xdatetime,
          text:       :textarea,
          json:       :jsonfield,
          string:     :textfield
        }[type] || :textfield
      end

      def configure_checkbox
        self.checked = value
        self.unchecked_value = false
        self.input_value = true
      end

      def configure_date_field
        self.submit_format = "Y-m-d"
        self[:format] ||= I18n.t("date", scope: 'netzke.formats', default: "Y-m-d")
      end
    end
  end
end
