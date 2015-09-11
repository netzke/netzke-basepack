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
    # == Persisting nodes' expand/collapse state
    #
    # If the model includes the `expanded` DB field, the expand/collapse state will get stored in the DB.
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
        c.mixins << "Netzke.mixins.Basepack.GridEventHandlers"
        c.translate *%w[are_you_sure confirmation]
        c.require :extensions
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
          data_adapter.find_root_records
        else
          data_adapter.find_record_children(data_adapter.find_record(params[:id]))
        end
      end

      # Override Grid::Services#read so we send records as key-value JSON (instead of array)
      def read(params = {})
        {}.tap do |res|
          records = get_records(params)
          res["children"] = records.map{|r| node_to_hash(r, final_columns(with_meta: true)).netzke_literalize_keys}
          res["total"] = count_records(params)  if config[:enable_pagination]
        end
      end

      def node_to_hash(record, columns)
        data_adapter.record_to_hash(record, columns).tap do |hash|
          if is_node_expanded?(record)
            hash["children"] = record.children.map {|child| node_to_hash(child, columns).netzke_literalize_keys}
          end
        end
      end

      def is_node_expanded?(record)
        record.respond_to?(:expanded) && record.expanded?
      end

      def js_configure(c)
        super

        c.title = c.title || self.class.js_config.properties[:title] || data_class.name.pluralize
        c.bbar = bbar
        # c.context_menu = context_menu
        c.columns = {items: js_columns}
        c.columns_order = columns_order
        c.pri = data_adapter.primary_key

        if c.default_filters
          populate_cols_with_filters(c)
        end

        c.root ||= data_adapter.record_to_hash(data_adapter.root, final_columns(with_meta: true)).netzke_literalize_keys
      end

      action :add do |a|
        a.handler = "onAddRecord" # overriding naming conventions as Ext 4 grid has its own onAdd method
        a.icon = :add
      end

      action :edit do |a|
        # a.disabled = true
        a.handler = :onEdit
        a.icon = :table_edit
      end

      action :apply do |a|
        a.disabled = config[:prohibit_update] && config[:prohibit_create]
        a.icon = :tick
      end

      action :del do |a|
        # a.disabled = true
        a.icon = :table_row_delete
      end

      component :add_window do |c|
        preconfigure_record_window(c)
        c.title = "Add #{data_class.model_name.human}"
        c.items = [:add_form]
        c.form_config.record = data_class.new(columns_default_values)
      end

      component :edit_window do |c|
        preconfigure_record_window(c)
        c.title = "Edit #{data_class.model_name.human}"
        c.items = [:edit_form]
      end

      component :multi_edit_window do |c|
        preconfigure_record_window(c)
        c.title = "Edit #{data_class.model_name.human.pluralize}"
        c.items = [:multi_edit_form]
      end

      endpoint :add_window__add_form__netzke_submit do |params, this|
        data = ActiveSupport::JSON.decode(params[:data])
        data["parent_id"] = params["parent_id"]
        this.merge!(component_instance(:add_window).
                    component_instance(:add_form).
                    submit(data, this))
        on_data_changed if this.set_form_values.present?
        this.delete(:set_form_values)
      end

      endpoint :server_update_node_state do |params, this|
        node = data_adapter.find_record(params[:id])
        if node.respond_to?(:expanded)
          node.expanded = params[:expanded]
          data_adapter.save_record(node)
        end
      end

      protected

      def bbar
        config.has_key?(:bbar) ? config[:bbar] : default_bbar
      end

      # Override to change the default bottom toolbar
      def default_bbar
        [:add, :edit, :apply, :del]
      end

      def preconfigure_record_window(c)
        c.klass = RecordFormWindow

        c.form_config = ActiveSupport::OrderedOptions.new.tap do |f|
          f.model = config[:model]
          f.persistent_config = config[:persistent_config]
          f.strong_default_attrs = config[:strong_default_attrs]
          f.mode = config[:mode]
          f.items = default_fields_for_forms
        end
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

      def set_defaults(c)
        # The nil? checks are needed because these can be already set in a subclass
        c.enable_edit_in_form = true if c.enable_edit_in_form.nil?
        c.enable_edit_inline = true if c.enable_edit_inline.nil?
        c.enable_extended_search = true if c.enable_extended_search.nil?
        c.enable_column_filters = true if c.enable_column_filters.nil?
        c.enable_pagination = true if c.enable_pagination.nil?
        c.rows_per_page = 30 if c.rows_per_page.nil?
        c.tools = %w{ refresh } if c.tools.nil?
      end
    end
  end
end
