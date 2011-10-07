module Netzke::Basepack::DataAdapters
  class AbstractAdapter

    # Used to determine if the given adapter should be used for the passed in class.
    def self.for_class?(member_class)
      false # override in subclass
    end

    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end

    def self.adapter_class(model_class)
      @subclasses.detect { |subclass| subclass.for_class?(model_class) } || AbstractAdapter
    end

    def initialize(model_class)
      @model_class = model_class
    end

    # end of generic stuff
  end
end