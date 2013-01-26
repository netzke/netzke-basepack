module Netzke
  module Basepack
    # Takes care of automatic field configuration in {Basepack::Form}
    class FieldConfig < AttrConfig
      def set_defaults!
        super

        self.attr_type ||= @data_adapter.attr_type(name)

        set_xtype! if xtype.nil?

        self.field_label ||= @data_adapter.human_attribute_name(name).gsub(/\s+/, " ")

        self.hidden = true if hidden.nil? && primary?
        self.hide_label = hidden if hide_label.nil?

        case attr_type
        when :boolean
          configure_checkbox!
        when :date
          configure_date_field!
        end
      end

    private

      def set_xtype!
        if association?
          set_xtype_for_association!
        else
          self.xtype = xtype_for_attr_type(attr_type)
        end
      end

      def set_xtype_for_association!
        assoc_name, method = name.split('__').map(&:to_sym)
        assoc_method_type = @data_adapter.get_assoc_property_type(assoc_name, method)
        if nested_attribute
          self.xtype = xtype_for_attr_type(assoc_method_type)
        else
          self.xtype = assoc_method_type == :boolean ? xtype_for_attr_type(assoc_method_type) : :netzkeremotecombo
        end
      end

      def xtype_for_attr_type(type)
        { integer:    :numberfield,
          boolean:    :checkboxfield,
          date:       :datefield,
          datetime:   :xdatetime,
          text:       :textarea,
          json:       :jsonfield,
          string:     :textfield
        }[type] || :textfield
      end

      def configure_checkbox!
        self.checked = value
        self.unchecked_value = false
        self.input_value = true
      end

      def configure_date_field!
        self.submit_format = "Y-m-d"
        self.format ||= I18n.t("date", scope: 'netzke.formats', default: "Y-m-d")
      end
    end
  end
end
