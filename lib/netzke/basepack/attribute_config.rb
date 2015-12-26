module Netzke
  module Basepack
    # TODO get rid
    class AttributeConfig < ActiveSupport::OrderedOptions
      def initialize(name)
        self.name = name.to_s
      end
    end
  end
end
