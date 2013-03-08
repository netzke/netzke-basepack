module Netzke
  module Basepack
    # Common parts of FieldConfig and ColumnConfig
    class AttrConfig < ActiveSupport::OrderedOptions
      def initialize(c, data_adapter)
        c = {name: c.to_s} if c.is_a?(Symbol) || c.is_a?(String)
        c[:name] = c[:name].to_s
        self.replace(c)

        @data_adapter = data_adapter || NullDataAdapter.new(nil)
      end

      def primary?
        @data_adapter.primary_key_attr?(self)
      end

      def association?
        @data_adapter.association_attr?(self)
      end

      def set_defaults!
        set_read_only! if read_only.nil?
      end

      def set_read_only!
        self.read_only = primary? ||
          !responded_to_by_model? &&
          !association?
      end

    private

      def responded_to_by_model?
        # if no model class is provided, assume the attribute is being responded to
        @data_adapter.model_class.nil? ||
          !setter.nil? ||
          @data_adapter.model_class.instance_methods.include?(:"#{name}=") ||
          @data_adapter.model_class.attribute_names.include?(name)
      end
    end
  end
end
