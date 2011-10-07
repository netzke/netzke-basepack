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

    # Returns records based on passed params. Implements:
    # * pagination
    # * filtering
    # * scopes
    #
    # Params is a hash that contains the following keys:
    # * :sort - sorting params, which is an array of hashes that contain the following keys in their turn:
    #   * :property - the field that is being sorted on
    #   * :diraction - "asc" or "desc"
    # * :limit - rows per page in pagination
    # * :start - page number in pagination
    # * :scope - the scope as described in Netzke::Basepack::GridPanel
    # * :filter - Ext filters
    #
    # The `columns` parameter may be used to use joins to address the n+1 query problem
    def get_records(params, columns)
      []
    end
  end
end