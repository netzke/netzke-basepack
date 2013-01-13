module Netzke
  module Basepack
    # Takes care of automatic field configuration in {Basepack::Form}
    class FieldConfig < ActiveSupport::OrderedOptions
      class NullDataAdapter < Netzke::Basepack::DataAdapters::AbstractAdapter
        def attr_type(name)
          :string
        end

        def attribute_names
          []
        end
      end

      def initialize(c, data_adapter)
        c = {name: c.to_s} if c.is_a?(Symbol) || c.is_a?(String)
        c[:name] = c[:name].to_s
        self.replace(c)

        @data_adapter = data_adapter || NullDataAdapter.new(nil)
      end

      def primary?
        @data_adapter.primary_key_name == name
      end

      def set_defaults!
        self.attr_type ||= @data_adapter.attr_type(self.name)

        set_xtype! if self.xtype.nil?

        self.field_label ||= @data_adapter.human_attribute_name(self.name).gsub(/\s+/, " ")

        self.hidden = true if self.hidden.nil? && self.primary?
        self.hide_label = self.hidden if self.hide_label.nil?

        case self.attr_type
        when :boolean
          configure_checkbox!
        when :date
          configure_date_field!
        end
      end

    private

      def set_xtype!
        if @data_adapter.association_attr?(self)
          set_xtype_for_association!
        else
          self.xtype = xtype_for_attr_type(self.attr_type)
        end
      end

      def set_xtype_for_association!
        assoc_name, method = self.name.split('__').map(&:to_sym)
        assoc_method_type = @data_adapter.get_assoc_property_type(assoc_name, method)
        if self.nested_attribute
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
        self.checked = self.value
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
