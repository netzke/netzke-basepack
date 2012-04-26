module Netzke::Basepack::DataAdapters
  # A concrete adapter should implement all the public instance methods of this adapter in order to support all the functionality of Basepack components.
  class AbstractAdapter

    # Returns primary key name of the model
    def primary_key_name
      "id"
    end

    # Returns a list of model attribute hashes, each containing `name`, `attr_type` and `default_value` (if set in the schema).
    # For association columns the name can have the double-underscore format, e.g.: `author__first_name`.
    # These attributes will be used by grids and forms to display default columns/fields.
    def model_attributes
      raise NotImplementedError
    end

    # Returns attribute type (as Symbol) given its name.
    def attr_type(attr_name)
      raise NotImplementedError
    end

    # Returns records based on passed params. Implements:
    # * pagination
    # * filtering
    # * scopes
    #
    # `params` is a hash that contains the following keys:
    #
    # * :sort - sorting params, which is an array of hashes that contain the following keys in their turn:
    #   * :property - the field that is being sorted on
    #   * :direction - "asc" or "desc"
    # * :limit - rows per page in pagination
    # * :start - page number in pagination
    # * :scope - the scope as described in Netzke::Basepack::GridPanel
    # * :filter - Ext filters
    #
    # The `columns` parameter may be used to use joins to address the n+1 query problem, and receives an array of column configurations
    def get_records(params, columns)
      []
    end

    # gets the first record
    def first
      @model_class.first
    end

    # Returns record count based on passed params. Implements:
    # * filtering
    # * scopes
    #
    # `params` is a hash that contains the following keys:
    #
    # * :scope - the scope as described in Netzke::Basepack::GridPanel
    # * :filter - Ext filters
    #
    # The `columns` parameter may be used to use joins to address the n+1 query problem, and receives an array of column configurations
    def count_records(params, columns)
      0
    end

    # Map a ORM type to a type symbol
    # Possible types to return
    # :integer
    # :boolean
    # :date
    # :datetime
    # :time
    # :text
    # :string
    #
    # Default implementation works for ActiveRecord
    def map_type type
      type
    end

    # gets the type of a model attribute for xtype mapping
    # i.e. get_assoc_property_type :author,:first_name should return :string
    # Possible types to return
    # :integer
    # :boolean
    # :date
    # :datetime
    # :time
    # :text
    # :string
    def get_assoc_property_type assoc_name, prop_name
      raise NotImplementedError
    end

    # like get_assoc_property_type but for non-association columns
    def get_property_type column
      column.type
    end
 
    # should return true if column is virtual
    def column_virtual? c
      raise NotImplementedError
    end

    # Returns options for comboboxes in grids/forms
    def combobox_options_for_column(column, method_options = {})
      raise NotImplementedError
    end

    # Returns the foreign key name for an association
    def foreign_key_for assoc_name
      raise NotImplementedError
    end

    # Returns the model class for association columns
    def class_for assoc_name
      raise NotImplementedError
    end

    # Destroys records with the provided ids
    def destroy(ids)
    end

    # Changes records position (e.g. when acts_as_list is used in ActiveRecord).
    #
    # `params` is a hash with the following keys:
    #
    # * :ids - ids of records to move
    # * :new_index - new starting position for the records to move
    def move_records(params)
    end

    # Returns a new record.
    def new_record(params = {})
      @model_class.new(params)
    end

    # give the data adapter the opportunity the set special options for
    # saving, must return true on success
    def save_record(record)
      record.save
    end

    # give the data adapter the opporunity to process error messages
    # must return an raay of the form ["Title can't be blank", "Foo can't be blank"]
    def errors_array(record)
      record.errors.to_a
    end

    # Finds a record by id, return nil if not found
    def find_record(id)
      @model_class.find(id)
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      raise NotImplementedError
    end



    # -- End of overridable methods

    # Abstract-adapter specifics
    #

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

  end
end
