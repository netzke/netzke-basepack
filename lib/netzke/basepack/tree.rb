module Netzke
  module Basepack
    # Ext.tree.Panel-based component with the following features:
    #
    # * CRUD operations
    # * Persistence of node expand/collapse state
    # * (TODO) Node reordering by DnD
    #
    # == Simple example
    #
    #     class Files < Netzke::Basepack::Tree
    #       def configure(c)
    #         super
    #         c.model = "FileRecord"
    #         c.columns = [
    #           {name: :name, xtype: :treecolumn}, # this column will show tree nodes
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
    #
    # [root]
    #
    #   By default, the component will pick whatever record is returned by `TreeModel.root`, and use it as the root
    #   record. However, sometimes the model table has multiple root records (whith `parent_id` set to `nil`), and all
    #   of them should be shown in the panel. To achive this, you can define the `root` config option,
    #   which will serve as a virtual root record for those records. You may set it to `true`, or a hash of
    #   attributes, e.g.:
    #
    #       c.root = {name: 'Root', size: 1000}
    #
    #   Note, that the root record can be hidden from the tree by specifying the `Ext.tree.Panel`'s `root_visible`
    #   config option set to `false`, which is probably what you want when you have multiple root records.
    #
    # [drag_drop]
    #
    #   (defaults to false) use drag and drop in the tree.
    #
    # == Persisting nodes' expand/collapse state
    #
    # If the model includes the `expanded` DB field, the expand/collapse state will get stored in the DB.
    class Tree < Netzke::Base
      NODE_ATTRS = {
        boolean: %w[leaf checked expanded expandable qtip qtitle],
        string: %w[icon icon_cls href href_target qtip qtitle]
      }

      include Netzke::Basepack::Grid::Configuration
      include Netzke::Basepack::Grid::Endpoints
      include Netzke::Basepack::Grid::Services
      include Netzke::Basepack::Grid::Actions
      include Netzke::Basepack::Grid::Components
      include Netzke::Basepack::Columns
      include Netzke::Basepack::Attributes
      include Netzke::Basepack::DataAccessor

      client_class do |c|
        c.extend = "Ext.tree.Panel"
        c.require :extensions
        c.mixins << "Netzke.mixins.Basepack.Columns"
        c.mixins << "Netzke.mixins.Basepack.GridEventHandlers"
        c.translate *%w[are_you_sure confirmation]
      end

      def self.server_side_config_options
        super + [:model]
      end

      def configure(c)
        set_defaults(c)
        super
      end

      def columns
        add_node_interface_methods(super)
      end

      def get_records(params)
        if params[:id] == 'root'
          model_adapter.find_root_records
        else
          model_adapter.find_record_children(model_adapter.find_record(params[:id]))
        end
      end

      # Override Grid::Services#read so we send records as key-value JSON (instead of array)
      def read(params = {})
        {}.tap do |res|
          records = get_records(params)
          res["children"] = records.map{|r| node_to_hash(r, final_columns).netzke_literalize_keys}
          res["total"] = count_records(params)  if config[:enable_pagination]
        end
      end

      def node_to_hash(record, columns)
        model_adapter.record_to_hash(record, columns).tap do |hash|
          if is_node_expanded?(record)
            hash["children"] = record.children.map {|child| node_to_hash(child, columns).netzke_literalize_keys}
          end
        end
      end

      def is_node_expanded?(record)
        record.respond_to?(:expanded) && record.expanded?
      end

      def configure_client(c)
        super

        c.title = c.title || self.class.client_class_config.properties[:title] || model_class.name.pluralize
        # c.context_menu = context_menu
        c.columns = {items: js_columns}
        c.columns_order = columns_order
        c.pri = model_adapter.primary_key

        if c.default_filters
          populate_cols_with_filters(c)
        end

        c.root ||= model_adapter.record_to_hash(model_adapter.root, final_columns).netzke_literalize_keys
      end

      endpoint :add_window__add_form__submit do |params|
        data = ActiveSupport::JSON.decode(params[:data])
        data["parent_id"] = params["parent_id"]
        client.merge!(component_instance(:add_window).
                    component_instance(:add_form).
                    submit(data, client))
        on_data_changed if client.set_form_values.present?
        client.delete(:set_form_values)
      end

      endpoint :update_node_state do |params|
        node = model_adapter.find_record(params[:id])
        if node.respond_to?(:expanded)
          node.expanded = params[:expanded]
          model_adapter.save_record(node)
        end
      end

      endpoint :update_parent_id do |records|
        records.each do |record|
          r = model_adapter.find_record(record[:id])
          update_record(r, record)
        end
      end

      private

      def update_record(record, attrs)
        if config.drag_drop && attrs['parentId']
          parent_id = attrs['parentId'] == 'root' ? nil : attrs['parentId']
          model_adapter.set_record_value_for_attribute(record, { name: 'parent_id' }, parent_id)
        end

        super
      end

      def default_bbar
        [:add, :edit, :apply, :del]
      end

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
          next unless model_adapter.model_respond_to?(a.to_sym)
          columns << {type: type, name: a, meta: true}
        end
      end

      def set_defaults(c)
        # The nil? checks are needed because these can be already set in a subclass
        c.enable_pagination = true if c.enable_pagination.nil?
        c.rows_per_page = 30 if c.rows_per_page.nil?
      end
    end
  end
end
