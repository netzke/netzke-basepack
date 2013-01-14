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
    end
  end
end
