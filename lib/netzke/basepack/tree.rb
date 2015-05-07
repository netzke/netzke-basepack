module Netzke
  module Basepack
    # Ext.tree.Panel-based component with the following features:
    #
    # * CRUD operations (only R is implemented atm)
    #
    # == Simple example
    #
    #     class Files < Netzke::Basepack::Tree
    #       def configure(c)
    #         super
    #         c.model = "FileRecord"
    #         c.columns = [
    #           {name: :name, xtype: :treecolumn},
    #           :size
    #         ]
    #       end
    #     end
    #
    # == Instance configuration
    #
    # The following config options are supported:
    #
    # [model]
    #
    #   Name of the ActiveRecord model that provides data to this Tree, e.g. "FileRecord"
    #   The model must respond to the following methods:
    #
    #   * TreeModel.root - the root record
    #   * TreeModel#children - child records
    #
    #   Note that the awesome_nested_set gem implements the above, so, feel free to use it.
    #
    # [columns]
    #
    #   An array of columns to be displayed in the tree. See the "Columns" section in the `Netzke::Basepack::Grid`.
    #   Additionally, you probably will want to specify which column will have the tree nodes UI by providing the
    #   `xtype` config option set to `:treecolumn`.
    class Tree < Netzke::Base
      NODE_ATTRS = {
        boolean: %w[leaf checked expanded expandable qtip qtitle],
        string: %w[icon icon_cls href href_target qtip qtitle]
      }

      include Netzke::Basepack::Grid::Endpoints
      include Netzke::Basepack::Grid::Services
      include Netzke::Basepack::Columns
      include Netzke::Basepack::DataAccessor

      js_configure do |c|
        c.extend = "Ext.tree.Panel"
        c.mixin
        c.mixins << "Netzke.mixins.Basepack.Columns"
        c.require :extensions
      end

      def self.server_side_config_options
        super + [:model]
      end

      def columns
        add_node_interface_methods(super)
      end

      def get_records(params)
        data_adapter.record_children(data_adapter.find_record(params[:id]))
      end

      # Override Grid::Services#read so we send records as key-value JSON (instead of array)
      def read(params = {})
        {}.tap do |res|
          records = get_records(params)
          res[:data] = records.map{|r| data_adapter.record_to_hash(r, final_columns(:with_meta => true))}
          res[:total] = count_records(params)  if config[:enable_pagination]
        end
      end

      def js_configure(c)
        super

        c.title = c.title || self.class.js_config.properties[:title] || data_class.name.pluralize
        # c.bbar = bbar
        # c.context_menu = context_menu
        c.columns = js_columns
        c.columns_order = columns_order
        c.inline_data = read if c.load_inline_data
        c.pri = data_adapter.primary_key

        if c.default_filters
          populate_cols_with_filters(c)
        end

        c.root = data_adapter.record_to_hash(data_adapter.root, final_columns(with_meta: true))
      end

      private

      # Adds attributes known to Ext.data.NodeInterface as meta columns (only those our model responds to)
      def add_node_interface_methods(columns)
        columns.clone.tap do |columns|
          NODE_ATTRS.each do |type, attrs|
            add_node_interface_methods_by_type!(columns, attrs, type)
          end
        end
      end

      def add_node_interface_methods_by_type!(columns, attrs, type)
        attrs.each do |a|
          next unless data_adapter.model_respond_to?(a.to_sym)
          columns << {attr_type: type, name: a, meta: true}
        end
      end
    end
  end
end
