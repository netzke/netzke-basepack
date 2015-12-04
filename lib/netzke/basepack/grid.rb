module Netzke
  module Basepack
    # Ext.grid.Panel-based component with the following features:
    #
    # * automatic default column configuration (overridable via config)
    # * infinite scrolling or pagination
    # * multi-line CRUD operations
    # * (multe-record) editing and adding records through a form
    # * one-to-many association support
    # * server-side sorting
    # * server-side filtering
    # * permissions
    # * persistent column resizing, moving and hiding
    # * complex query search with preset management
    #
    # == Instance configuration
    #
    # The following config options are supported:
    #
    # [model]
    #
    #   Name of the ActiveRecord model that provides data to this Grid, e.g. "User". Required.
    #
    # [columns]
    #
    #   An array of columns to be displayed in the grid; each column may be represented by a symbol (representing the
    #   model's attribute name), or a hash (when extra configuration is needed - see the "Columns" section below).
    #   Defaults to the model's attributes.
    #
    # [scope]
    #
    #   A Proc object used to scope out grid data. Receives the current relation as a parameter and must return the modified relation. For example:
    #
    #      class Books < Netzke::Basepack::Grid
    #        def configure(c)
    #          c.model = "Book"
    #          super
    #          c.scope = ->(r) { r.where(author_id: 1) }
    #        end
    #      end
    #
    # [role]
    #
    #   Role for ActiveModel mass-assignment security
    #
    # [strong_default_attrs]
    #
    #   (defaults to {}) a hash of attributes to be merged atop of every created/updated record, e.g. +role_id: 1+
    #
    # [edit_inline]
    #   TODO: rename to inline_edit
    #   Whether record editing should happen inline (as opposed to using a form). When set to +true+, automatically sets
    #   +paging+ to +true+. Defaults to +false+.
    #
    # [enable_context_menu]
    #
    #   (defaults to true) enable rows context menu
    #
    # [context_menu]
    #
    #   An array of actions (e.g. [:edit, "-", :del] - see the Actions section) or +false+ to disable the context menu
    #
    # [paging]
    #
    #   Set to +true+ to use pagination instead of infinite scrolling. Is automatically set to
    #   +true+ if +edit_inline+ is +true+. Defaults to +false+.
    #
    # [store_config]
    #
    #   Extra configuration for the JS class's internal store (Ext.data.ProxyStore), which will override Netzke's defaults. For example, to
    #   modify amount of records per page (defaults to 25), do:
    #
    #     def configure(c)
    #       c.paging = true
    #       c.store_config = {page_size: 100}
    #       super
    #     end
    #
    #   Another example, enable (multi) sorting initially:
    #
    #     def configure(c)
    #       c.store_config = {sorters: [:title, {property: :author__first_name, direction: :DESC}]}
    #       super
    #     end
    #
    # [disable_dirty_page_warning]
    #
    #   Do not warn the user about dirty records on the page when changing the page. Defaults to +false+.
    #
    # [prohibit_create]
    #
    #   when set to +true+ prevents user from adding data
    #
    # [prohibit_update]
    #
    #   when set to +true+ prevents user from editing data
    #
    # [prohibit_read]
    #
    #   when set to +true+ prevents user from reading data
    #
    # [prohibit_delete]
    #
    #   when set to +true+ prevents user from deleting data
    #
    # == Columns
    #
    # Columns are configured by passing an array to the +columns+ option. Each element in the array is either the name
    # of model's (virtual) attribute (in which case the configuration will be fully automatic), or a hash that may
    # contain the following configuration options as keys:
    #
    # [name]
    #
    #   (required) name of the column, that may correspond to the model's (virtual) attribute
    #
    # [read_only]
    #
    #   A boolean that defines if the cells in the column should be editable
    #
    # [filterable]
    #
    #   Set to false to disable filtering on this column
    #
    # [getter]
    #
    #   A lambda that receives a record as a parameter, and is expected to return a string that will be sent to the cell
    #   (can be HTML code), e.g.:
    #
    #     getter: ->(r){ [r.first_name, r.last_name].join }
    #
    #   In case of relation used in relation, passes the last record to lambda, e.g.:
    #
    #     name: author__books__first__name, getter: ->(r){ r.title }
    #     # r == author.books.first
    #
    # [setter]
    #
    #   A lambda that receives a record as first parameter, and the value passed from the cell as the second parameter,
    #   and is expected to modify the record accordingly, e.g.:
    #
    #     setter: ->(r,v){ r.first_name, r.last_name = v.split(" ") }
    #
    # [scope]
    #
    #   The scope for one-to-many association column. Same syntax applies as for scoping out records for the grid
    #   itself. See "One-to-many association support" for details.
    #
    # [sorting_scope]
    #
    #   A Proc object used for sorting by the column. This can be useful for sorting by a virtual column. The Proc
    #   object will get the relation as the first parameter, and the sorting direction as the second. Example:
    #
    #     columns => [{ name: "complete_user_name", sorting_scope: ->(rel, dir){ order("users.first_name #{dir.to_s}, users.last_name #{dir.to_s}") }, ...]
    #
    # [filter_with]
    #
    #   A Proc object that receives the relation, the value to filter by and the operator. This allows for more flexible
    #   handling of basic filters and enables filtering of virtual columns. Example:
    #
    #     columns => [{ name: "complete_user_name", filter_with: lambda{|rel, value, op| rel.where("first_name like ? or last_name like ?", "%#{value}%", "%#{value}%" ) } }, ...]
    #
    # [filter_association_with]
    #
    #   A Proc object that receives the relation and the value to filter by. This allows flexible handling of live search on association field input.
    #   Example:
    #
    #     columns => [{ name: "author__name", filter_association_with: lambda{|rel, value| rel.where("first_name like ? or last_name like ?", "%#{value}%", "%#{value}%" ) } }, ...]
    #
    # [format]
    #
    #   The format to display data in case of date and datetime columns, e.g. 'Y-m-d g:i:s'.
    #
    # [excluded]
    #
    #   When true, this column will not be used in the grid (not even in the hidden mode)
    #
    # [meta]
    #
    #   When set to +true+, the data for this column will be available in the grid store, but the column won't be shown
    #   (as if +excluded+ were set to +true+).
    #
    # [blank_line]
    #
    #   The blank line for one-to-many association columns, defaults to "---". Set to false to exclude completely.
    #
    # [editor]
    #
    #   A hash that will override the automatic editor configuration. For example, for one-to-many association column
    #   you may set it to +{min_chars: 1}+, which will be passed to the combobox and make it query its remote data after
    #   entering 1 character (instead of default 4).
    #
    # Besides these options, a column can receive any meaningful config option understood by
    # Ext.grid.column.Column[http://docs.sencha.com/ext-js/4-1/#!/api/Ext.grid.column.Column] (e.g. +hidden+)
    #
    # === Customizing columns by extending Grid
    #
    # Grid itself always uses the columns provided in the `columns` config option. But this behavior can be changed by
    # overriding the `columns` method, which follows the same semantics as the `columns` config option. This can be
    # used, for example, for extending the list of columns provided in the config:
    #
    #     def columns
    #       super + [:extra_column]
    #     end
    #
    # === Configuring default filters on grid columns
    #
    # Default Filters can either be configured on the grid itself
    #
    #     def configure(c)
    #       super
    #       c.default_filters = [{name: "Mark"}, {age: {gt: 10}}]
    #     end
    #
    # or as a component configuration
    #
    #      component :tasks |c|
    #        c.klass = TaskGrid
    #        c.default_filters = [{due_date: {before: Time.now}}]
    #      end
    #
    # == One-to-many association support
    #
    # If the model bound to a grid +belongs_to+ another model, Grid can display an "assocition column" - where the user
    # can select the associated record from a drop-down box. You can specify which method of the association should be
    # used as the display value for the drop-down box options by using the double-underscore notation on the column
    # name, where the association name is separated from the association method by "__" (double underscore). For
    # example, let's say we have a Book that +belongs_to+ model Author, and Author responds to +first_name+. This way,
    # the book grid can have a column defined as follows:
    #
    #     {name: "author__first_name"}
    #
    # Grid will detect it to be an association column, and will use the drop-down box for selecting an author, where the
    # list of authors will be represented by the author's first name.
    #
    # In order to scope out the records displayed in the drop-down box, the +scope+ column option can be used, e.g.:
    #
    #     {name: "author__first_name", scope: ->(relation){relation.where(popular: true)}
    #
    # == Add/Edit/Search forms
    #
    # Add/Edit/Multi-edit/Search forms are each wrapped in a separate +Basepack::Window+-descending component (called
    # +RecordFormWindow+ for the add/edit forms, and +SearchWindow+ for the search form), and can be overridden
    # individually as any other child component.
    #
    # === Overriding windows
    #
    # Override the following direct child components to change the looks of the pop-up windows: +:add_window+,
    # +:edit_window+, +:multi_edit_window+, and +:search_window+. For example, to override the title of the Add form,
    # do:
    #
    #     component :add_window do |c|
    #       super c
    #       c.title = "Adding new record"
    #     end
    #
    # === Modifying forms
    #
    # The forms will by default display the fields that correspond to the configured columns, taking over meaningful
    # configuration options (e.g. +text+ will be converted into +fieldLabel+).
    # You may override the default fields displayed in the all add/edit forms by overriding the
    # +default_fields_for_forms+ method, which should return an array understood by the +items+ config property of the
    # +Form+. If you need to use a custom +Basepack::Form+-descending class instead of +Form+, you need to override the
    # +preconfigure_record_window+ method:
    #
    #     def preconfigure_record_window(c)
    #       super
    #       c.form_config.klass = UserForm
    #     end
    #
    # To individually override forms, you should override the wrapping window components, as shown in the previous
    # session. E.g., to modify the set of fields in the Add form:
    #
    #     component :add_window do |c|
    #       super c
    #       c.form_config.items = [:title]
    #     end
    #
    # == Actions
    # You can override Grid's actions to change their text, icons, and tooltips (see
    # http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Actions).
    #
    # Grid implements the following actions:
    #
    # [add]
    #
    #   Add record
    #
    # [del]
    #
    #   Delete record(s)
    #
    # [edit]
    #
    #   Edit record(s)
    #
    # [apply]
    #
    #   Applying inline changes
    #
    # [search]
    #
    #   Advanced searching
    class Grid < Netzke::Base
      include self::Endpoints
      include self::Services
      include Netzke::Basepack::Columns
      include Netzke::Basepack::DataAccessor
      include Netzke::Core::ConfigToDslDelegator

      # JavaScript class configuration
      client_class do |c|
        c.extend = "Ext.grid.Panel"
        c.include :advanced_search
        c.include :remember_selection

        c.mixins << "Netzke.mixins.Basepack.Columns"
        c.mixins << "Netzke.mixins.Basepack.GridEventHandlers"

        c.translate *%w[are_you_sure confirmation proceed_with_unapplied_changes]

        # JavaScript includes
        ex = Netzke::Core.ext_path.join("examples")

        c.require :extensions
      end

      # Allows children classes to simply do:
      #
      #     model "User"
      # TODO: get rid of it for less entropy
      delegates_to_dsl :model

      def configure_client(c)
        super

        c.title = c.title || self.class.client_class_config.properties[:title] || data_class.name.pluralize
        c.bbar = bbar
        c.context_menu = context_menu
        c.columns = {items: js_columns}
        c.columns_order = columns_order
        c.pri = data_adapter.primary_key
        if c.default_filters
          populate_cols_with_filters(c)
        end
      end

      # FIXME: move to Columns
      def populate_cols_with_filters(c)
        c.default_filters.each do |f|

          c.columns[:items].each do |col|
            if col[:name].to_sym == f[:column].to_sym
              if f[:value].is_a?(Hash)
                val = {}
                f[:value].each do |k,v|
                  val[k] = (v.is_a?(Time) || v.is_a?(Date) || v.is_a?(ActiveSupport::TimeWithZone)) ? Netzke::Core::JsonLiteral.new("new Date('#{v.strftime("%m/%d/%Y")}')") : v
                end
              else
                val = f[:value]
              end
              new_filter = {value: val, active: true}
              if col[:filter]
                col[:filter].merge! new_filter
              else
                col[:filter] = new_filter
              end
            end
          end
        end
        c.default_filters = nil
      end

      def bbar
        config.has_key?(:bbar) ? config[:bbar] : default_bbar
      end

      def context_menu
        config.has_key?(:context_menu) ? config[:context_menu] : default_context_menu
      end

      # Override to change the default bottom toolbar
      def default_bbar
        res = %w{ add edit }.map(&:to_sym)
        res << :apply if config[:edit_inline]
        res << :del
        res << "-" << :search
        res
      end

      # Override to change the default context menu
      def default_context_menu
        res = [:edit]
        res << :del if !config[:read_only]
        res
      end

      action :add do |a|
        a.disabled = config[:prohibit_create]
        a.handler = "onAddRecord" # overriding naming conventions as Ext 4 grid has its own onAdd method
        a.icon = :add
      end

      action :edit do |a|
        a.disabled = true
        a.icon = :table_edit
      end

      action :del do |a|
        a.disabled = true
        a.icon = :table_row_delete
      end

      action :apply do |a|
        a.disabled = config[:prohibit_update] && config[:prohibit_create]
        a.icon = :tick
      end

      action :search do |a|
        a.enable_toggle = true
        a.icon = :find
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

      component :search_window do |c|
        c.klass = SearchWindow
        c.model = config.model
        c.fields = attributes_for_search
      end

      protected

      def validate_config(c)
        raise ArgumentError, "Grid requires a model" if c.model.nil?
        c.paging = true if c.edit_inline
        if c.tools.nil?
          c.tools = [{ type: :refresh, handler: f(:on_refresh) }]
        end
        super
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

      def self.server_side_config_options
        super + [:scope]
      end
    end
  end
end
