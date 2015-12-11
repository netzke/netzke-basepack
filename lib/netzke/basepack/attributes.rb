module Netzke
  module Basepack
    # This module is encluded in +Grid+, +Form+, and +Tree+. It allows configuring specific model attributes.
    #
    # To override default configuration for a model attribute (e.g. to change its label or read-only property) use the
    # +attribute_overrides+ configuration option for the component, or the +attribute+ DSL method. This will have effect
    # on both columns and form fields.
    #
    # For example, to make the address attribute read-only:
    #
    #      class Users < Netzke::Basepack::Grid
    #        def configure(c)
    #          super
    #          c.model = User
    #        end
    #
    #        attribute :address do |c|
    #          c.read_only = true
    #        end
    #      end
    #
    # Using the +attribute_overrides+ config option may be handy when building composite components. E.g. in a tab panel
    # nesting multiple grids, you may want to override specific attributes for a specific grid:
    #
    #      class ManagmentPanel < Netzke::Base
    #        client_class do |c|
    #          c.extend = "Ext.tab.Panel"
    #        end
    #
    #        def configure(c)
    #          super
    #          c.items = [:users, :roles]
    #        end
    #
    #        component :users do |c|
    #          c.attribute_overrides = {
    #            birth_date: {
    #              excluded: true # exclude this column from the grid and forms
    #            }
    #          }
    #        end
    #
    #        component :roles
    #      end
    #
    # The following attribute config options are available:
    #
    # [read_only]
    #
    #   A boolean that defines whether the attribute should be editable via grid/form.
    #
    # [getter]
    #
    #   A lambda that receives a record as a parameter, and is expected to return the value used in the grid cell or
    #   form field, e.g.:
    #
    #     getter: ->(r){ [r.first_name, r.last_name].join }
    #
    #   In case of relation used in relation, passes the last record to lambda, e.g.:
    #
    #     name: author__books__first__name, getter: ->(r){ r.title }
    #     r #=> author.books.first
    #
    # [setter]
    #
    #   A lambda that receives a record as first parameter, and the value passed from the cell/field as the second parameter,
    #   and is expected to modify the record accordingly, e.g.:
    #
    #     setter: ->(r,v){ r.first_name, r.last_name = v.split(" ") }
    #
    # [scope]
    #
    #   The scope for association attribute. Same syntax applies as for scoping out records for the grid.
    #
    # [filter_association_with]
    #
    #   A Proc object that receives the relation and the value to filter by. Example:
    #
    #     column :author__name do |c|
    #       c.filter_association_with = ->(rel, value){rel.where("first_name like ? or last_name like ?", "%#{value}%", "%#{value}%" ) }
    #     end
    #
    # [format]
    #
    #   The format to display data in case of date and datetime attributes, e.g. 'Y-m-d g:i:s'.
    #
    # [excluded]
    #
    #   When true, this attribute will not be used
    #
    # [meta]
    #
    #   When set to +true+, the data for this column will be available in the grid store, but the actual column won't be
    #   created (as if +excluded+ were set to +true+).
    #
    # [blank_line]
    #
    #   The blank line for one-to-many association columns, defaults to "---". Set to false to exclude completely.
    #
    # [type]
    #
    #   When adding a virtual attribute to the grid, it may be useful to specify its type, so the column editor (and the
    #   form field) are configured properly.
    #
    # == Specifying column or form field configs
    #
    # Sometimes it's handy to specify grid/form-specific config options for a given attribute. For that, set the
    # +column_config+ and +field_config+ keys. For example:
    #
    #        attribute :address do |c|
    #          c.column_config = { width: 200 }
    #          c.field_config = { xtype: :displayfield }
    #        end
    module Attributes
      extend ActiveSupport::Concern

      ATTRIBUTE_METHOD_NAME = "%s_attribute"

      included do
        class_attribute :declared_attribute_names
        self.declared_attribute_names = []
      end

      module ClassMethods
        # Adds/overrides an attribute config, e.g.:
        #
        #     attribute :price do |c|
        #       c.read_only = true
        #     end
        def attribute(name, &block)
          method_name = ATTRIBUTE_METHOD_NAME % name
          define_method(method_name, &block)

          # we *must* use a writer here
          self.declared_attribute_names = declared_attribute_names + [name]
        end
      end

      def attribute_overrides
        return @attribute_overrides if @attribute_overrides

        declared = self.class.declared_attribute_names.reduce({}) do |res, name|
          c = AttributeConfig.new(name)
          augment_attribute_config(c)
          res.merge!(name => c)
        end

        @attribute_overrides = (config.attribute_overrides || {}).deep_merge(declared)
      end

      def augment_attribute_config(c)
        send(ATTRIBUTE_METHOD_NAME % c.name, c)
      end

      def association_attr?(attr)
        !!attr[:name].to_s.index("__")
      end

      # Returns a hash of association attribute default values. Used when creating new records with association attributes that have a default value.
      def association_value_defaults(cols)
        @_default_association_values ||= {}.tap do |values|
          cols.each do |c|
            next unless association_attr?(c) && c[:default_value]

            assoc_name, assoc_method = c[:name].split '__'
            assoc_class = model_adapter.class_for(assoc_name)
            assoc_data_adapter = Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(assoc_class).new(assoc_class)
            assoc_instance = assoc_data_adapter.find_record c[:default_value]
            values[c[:name]] = assoc_instance.send(assoc_method)
          end
        end
      end
    end
  end
end
