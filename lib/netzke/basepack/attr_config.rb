module Netzke
  module Basepack
    # Base for FieldConfig and ColumnConfig
    class AttrConfig < ActiveSupport::OrderedOptions
      def initialize(c, model_adapter)
        c = {name: c.to_s} if c.is_a?(Symbol) || c.is_a?(String)
        c[:name] = c[:name].to_s
        self.replace(c)

        @model_adapter = model_adapter
      end

      def primary?
        @model_adapter.primary_key_attr?(self)
      end

      def association?
        @model_adapter.association_attr?(self)
      end

      def set_defaults
        set_read_only if read_only.nil?
      end

      def set_read_only
        self.read_only = primary? ||
          !responded_to_by_model? &&
          !association?
        self.delete(:read_only) if read_only == false
      end

    private

      def default_label
        @model_adapter.human_attribute_name(name)
      end

      def responded_to_by_model?
        # if no model class is provided, assume the attribute is being responded to
        @model_adapter.model.nil? ||
          !setter.nil? ||
          @model_adapter.model.instance_methods.include?(:"#{name}=") ||
          @model_adapter.model.attribute_names.include?(name)
      end
    end
  end
end
