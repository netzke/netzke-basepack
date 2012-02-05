module Netzke::Basepack::DataAdapters
  class SequelAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= Sequel::Model
    end

    def get_records(params, columns=[])
    end

    def count_records(params, columns=[])
    end

    def map_type type
      @typemap ||= {
      }
      @typemap[type]
    end

    def get_assoc_property_type assoc_name, prop_name
    end

    # like get_assoc_property_type but for non-association columns
    def get_property_type column
    end

    def column_virtual? c
    end

    # Returns options for comboboxes in grids/forms
    def combobox_options_for_column(column, method_options = {})
    end

    def foreign_key_for assoc_name
    end

    # Returns the model class for association columns
    def klass_for assoc_name
    end

    def destroy(ids)
    end

    def find_record(id)
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
    end

    def move_records(params)
    end

    # Needed for seed and tests
    def last
    end

    def destroy_all
    end

    private

    def apply_column_filters(relation, column_filter)
    end

  end

end
