module Netzke::Basepack::DataAdapters
  # A concrete adapter should implement all the public instance methods of this adapter in order to support all the functionality of Basepack components.
  class AbstractAdapter
    attr_accessor :model_class

    # Returns primary key name of the model
    def primary_key
      "id"
    end

    # Whether passed attribute config represents the primary key
    def primary_key_attr?(a)
      a[:name].to_s == primary_key
    end

    # List of model attribute names as strings
    def attribute_names
      []
    end

    # Returns a list of model attribute hashes, each containing `name`, `attr_type` and `default_value` (if set in the schema).
    # For association columns the name can have the double-underscore format, e.g.: `author__first_name`.
    # These attributes will be used by grids and forms to display default columns/fields.
    def model_attributes
      []
    end

    # Returns attribute type (as Symbol) given its name.
    def attr_type(attr_name)
      :string
    end

    # Returns records based on passed params. Implements:
    # * pagination
    # * filtering
    # * scopes
    #
    # `params` is a hash that contains the following keys:
    #
    # [sorters]
    #   sorting params, which is an array of hashes that contain the following keys in their turn:
    #   [property]
    #     the field that is being sorted on
    #   [direction]
    #     "asc" or "desc"
    # [limit]
    #   rows per page in pagination
    # [start]
    #   page number in pagination
    # [scope]
    #   the scope as described in Netzke::Basepack::Grid
    # [filters]
    #   an array of hashes representing a filter query, where the hashes have the following keys:
    #   [attr]
    #     Name of the (virtual) model attribute to apply the filter to
    #   [operator]
    #     Operator for this filter. Possible values are: +contains+, +eq+, +gt+, +gteq+, +lt+, +lteq+
    #   [value]
    #     The value for this filter
    # [query]
    #
    # The `columns` parameter may be used to use joins to address the n+1 query problem, and receives an array of column configurations
    def get_records(params, columns)
      []
    end

    # gets the first record
    def first
      nil
    end

    # Returns record count based on passed params. Implements:
    # * filtering
    # * scopes
    #
    # `params` is a hash that contains the following keys:
    #
    # * :scope - the scope as described in Netzke::Basepack::Grid
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
    def virtual_attribute? c
      raise NotImplementedError
    end

    # Returns options for comboboxes in grids/forms
    # +attr+ - column/field configuration; note that it will in its turn provide:
    # * +name+ - attribute name
    # * +scope+ - searching scope (optional)
    # +query+ - whatever is entered in the combobox
    def combo_data(attr, query = "")
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

    # Finds a record by id, return nil if not found
    def find_record(id)
      nil
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      raise NotImplementedError
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
      nil
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

    # Whether an attribute (by name) is an association one
    def association_attr?(attr)
      !!attr[:name].to_s.index("__")
    end

    # Transforms a record to an array of values according to the passed attributes
    # +attrs+ - array of attribute config hashes
    def record_to_array(r, attrs)
      []
    end

    # Transforms a record to a hash of values according to the passed attributes
    # +attrs+ - array of attribute config hashes
    def record_to_hash(r, attrs)
      {}
    end

    # Returns a hash of association values for given record, e.g.:
    #
    #     {author__first_name: "Michael"}
    def assoc_values(r, attr_hash) #:nodoc:
      {}.tap do |values|
        attr_hash.each_pair do |name,c|
          values[name] = record_value_for_attribute(r, c, true) if association_attr?(c)
        end
      end
    end

    # Fetches the value specified by an (association) attribute
    # If +through_association+ is true, get the value of the association by provided method, *not* the associated record's id
    # E.g., author__name with through_association set to true may return "Vladimir Nabokov", while with through_association set to false, it'll return author_id for the current record
    def record_value_for_attribute(r, a, through_association = false)
    end

    # Assigns new value to an (association) attribute in a given record
    # +role+ - role provided for mass assignment protection
    def set_record_value_for_attribute(record, attr, value)
    end

    # Returns human attribute name
    def human_attribute_name(name)
      name.to_s.humanize
    end

    # Returns root record for tree-like data
    def root
      model_class.root
    end

    # Children records for given record in the tree; extra scope (lambda/proc) is optional
    def find_record_children(r, scope = nil)
      r.children.extend_with(scope)
    end

    # All root records in the tree
    def find_root_records(scope)
      model_class.where(parent_id: nil).extend_with(scope)
    end

    # Does record respond to given method?
    def model_respond_to?(method)
      @model_class.instance_methods.include?(method)
    end

    # -- End of overridable methods

    # Abstract-adapter specifics
    #
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
