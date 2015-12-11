module Netzke
  module Basepack
    class AttributeConfig < ActiveSupport::OrderedOptions
      def initialize(name)
        self.name = name.to_s
      end
    end
  end
end
