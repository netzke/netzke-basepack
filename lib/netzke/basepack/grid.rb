require "netzke/basepack/grid/services"
require 'netzke/basepack/column_config'

module Netzke
  module Basepack
    # {Ext.grid.Panel}[http://docs.sencha.com/ext-js/4-1/#!/api/Ext.grid.Panel] -based component with the following features:
    #
    # * automatic column configuration based on used ORM
    # * pagination
    # * multi-line CRUD operations
    # * (multe-record) editing and adding records through a form
    # * one-to-many association support
    # * server-side sorting
    # * filtering
    # * complex query search with preset management
    # * persistent column resizing, moving and hiding
    # * permissions
    # * virtual attribute support
    #
    # == Instance configuration
    # The following config options are supported:
    # [:+model+]
    #   Name of the ActiveRecord model that provides data to this Grid, e.g. "User"
    # [:+columns+]
    #   An array of columns to be displayed in the grid; each column may be represented by a symbol (representing the model's attribute name), or a hash (when extra configuration is needed). See the "Columns" section below.
    # [:+scope+]
    #   Specifies how the data should be filtered.
    #   When it's a symbol, it's used as a scope name.
    #   When it's a string, it's a SQL statement (passed directly to +where+).
    #   When it's a hash, it's a conditions hash (passed directly to +where+).
    #   When it's an array, it's expanded into an SQL statement with arguments (passed directly to +where+), e.g.:
    #
    #     scope: ["id > ?", 100])
    #
    # [:+role+]
    #   Role for ActiveModel mass-assignment security
    # [:+strong_default_attrs+]
    #   (defaults to {}) a hash of attributes to be merged atop of every created/updated record, e.g. +role_id: 1+
    # [:+enable_column_filters+]
    #   (defaults to true) enable filters in column's context menu
    # [:+enable_edit_in_form+]
    #   (defaults to true) provide buttons into the toolbar that activate editing/adding records via a form
    # [:+enable_extended_search+]
    #   (defaults to true) provide a button into the toolbar that shows configurable search form
    # [:+enable_context_menu+]
    #   (defaults to true) enable rows context menu
    # [:+context_menu+]
    #   An array of actions (e.g. [:edit, "-", :del] - see the Actions section) or +false+ to disable the context menu
    # [:+enable_pagination+]
    #   (defaults to true) enable pagination
    # [:+rows_per_page+]
    #   (defaults to 30) number of rows per page (ignored when +enable_pagination+ is set to +false+)
    # [:+load_inline_data+]
    #   (defaults to false) grid is being loaded along with its initial data; use with precaution, preferred method is auto-loading of data in a separate server request (see +data_store+)
    # [:+data_store+]
    #   (defaults to {}) extra configuration for the JS class's internal store (see {Ext.data.Store}[http://docs.sencha.com/ext-js/4-1/#!/api/Ext.data.Store] ). For example, to disable auto loading of data, do:
    #
    #     data_store: {auto_load: false}
    #
    # == Columns
    # Columns are configured by passing an array to the +columns+ option. Each element in the array is either the name of model's (virtual) attribute (in which case the configuration will be fully automatic), or a hash that may contain the following configuration options as keys:
    #
    # [:+name+]
    #   (required) name of the column, that may correspond to the model's (virtual) attribute
    # [:+read_only+]
    #   A boolean that defines if the cells in the column should be editable
    # [:+filterable+]
    #   Set to false to disable filtering on this column
    # [:+getter+]
    #   A lambda that receives a record as a parameter, and is expected to return a string that will be sent to the cell (can be HTML code), e.g.:
    #
    #     getter: ->(r){ [r.first_name, r.last_name].join }
    #
    # [:+setter+]
    #   A lambda that receives a record as first parameter, and the value passed from the cell as the second parameter, and is expected to modify the record accordingly, e.g.:
    #
    #     :setter => ->(r,v){ r.first_name, r.last_name = v.split(" ") }
    #
    # [:+scope+]
    #   The scope for one-to-many association column. Same syntax applies as for scoping out records for the grid itself. See "One-to-many association support" for details.
    #
    # [:+sorting_scope+]
    #   The name of the scope used for sorting the column. This can be useful for virtual columns for example. The scope will get one parameter specifying the direction (:asc or :desc). Example:
    #
    #     columns => [{ name: "complete_user_name", sorting_scope: :sort_user_by_full_name }, ...]
    #
    #     class User < ActiveRecord::Base
    #       scope :sort_user_by_full_name, ->(dir){
    #         order("users.first_name #{dir.to_s}, users.last_name #{dir.to_s}")
    #       }
    #     end
    #
    # [:+filter_with+]
    #   A lambda that receives the relation, the value to filter by and the operator. This allows for more flexible handling of basic filters and enables filtering of virtual columns. Example:
    #
    #     columns => [{ name: "complete_user_name", filter_with: lambda{|rel, value, op| rel.where("first_name like ? or last_name like ?", "%#{value}%", "%#{value}%" ) } }, ...]
    #
    # [:+format+]
    #   The format to display data in case of date and datetime columns, e.g. 'Y-m-d g:i:s'.
    # [:+excluded+]
    #   When true, this column will not be used in the grid (not even in the hidden mode)
    # [:+blank_line+]
    #   The blank line for one-to-many association columns, defaults to "---". Set to false to exclude completely.
    #
    # Besides these options, a column can receive any meaningful config option understood by {Ext.grid.column.Column}(http://docs.sencha.com/ext-js/4-1/#!/api/Ext.grid.column.Column) (e.g. +hidden+)
    #
    # === Customizing columns by extending Grid
    # Grid itself always uses the columns provided in the `columns` config option. But this behavior can be changed by overriding the `columns` method, which follows the same semantics as the `columns` config option. This can be used, for example, for extending the list of columns provided in the config:
    #
    #     def columns
    #       super + [:extra_column]
    #     end
    #
    #
    # == One-to-many association support
    # If the model bound to a grid +belongs_to+ another model, Grid can display an "assocition column" - where the user can select the associated record from a drop-down box. You can specify which method of the association should be used as the display value for the drop-down box options by using the double-underscore notation on the column name, where the association name is separated from the association method by "__" (double underscore). For example, let's say we have a Book that +belongs_to+ model Author, and Author responds to +first_name+. This way, the book grid can have a column defined as follows:
    #
    #     {name: "author__first_name"}
    #
    # Grid will detect it to be an association column, and will use the drop-down box for selecting an author, where the list of authors will be represented by the author's first name.
    #
    # In order to scope out the records displayed in the drop-down box, the +scope+ column option can be used, e.g.:
    #
    #     {name: "author__first_name", scope: ->(relation){relation.where(:popular => true)}
    #
    # == Add/edit forms
    # The forms will by default display the fields that correspond to the configured columns, taking over meaningful configuration options (e.g. +text+ will be converted into +fieldLabel+).
    # You may override the default fields displayed in the forms by overriding the +default_fields_for_forms+ method, which should return an array understood by the +items+ config property of the +Form+. If you need to use a custom class instead of +Form+, you need to override the +preconfigure_record_window+ method:
    #
    #     def preconfigure_record_window(c)
    #       super
    #       c.form_config.klass = UserForm
    #     end
    #
    #
    # == Actions
    # You can override Grid's actions to change their text, icons, and tooltips (see http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Actions).
    #
    # Grid implements the following actions:
    # [:+add+]
    #   Inline adding of a record
    # [:+del+]
    #   Deletion of records
    # [:+edit+]
    #   Inline editing of a record
    # [:+apply+]
    #   Applying inline changes
    # [:+add_in_form+]
    #   Adding a record in a form
    # [:+edit_in_form+]
    #   (multi-record) editing in a forrm
    # [:+search+]
    #   Advanced searching
    #
    #
    #
    # == Class-level configuration
    #
    # Configuration on this level is effective during the life-time of the application. One place for setting these options is initializers:
    #
    #    Netzke::Basepack::Grid.setup do |c|
    #      c.edit_in_form_available = false
    #      c.advanced_search_available = false
    #      c.column_filters_available = false
    #    end
    #
    # Most of these options influence the amount of JavaScript code that is generated for this component's class, in the way that the less functionality is enabled, the less code is generated.
    #
    # The following class configuration options are available:
    # [:+column_filters_available+]
    #   (defaults to true) include code for the filters in the column's context menu
    # [:+edit_in_form_available+]
    #   (defaults to true) include code for (multi-record) editing and adding records through a form
    # [:+advanced_search_available+]
    #   (defaults to true) include code for extended configurable search
    class Grid < Netzke::Base
      include self::Services
      include Columns
      include DataAccessor
      include Netzke::Core::ConfigToDslDelegator

      class_attribute :column_filters_available
      self.column_filters_available = true

      class_attribute :advanced_search_available
      self.advanced_search_available = true

      class_attribute :edit_in_form_available
      self.edit_in_form_available = true

      class_attribute :edit_inline_available
      self.edit_inline_available = true

      # JavaScript class configuration
      js_configure do |c|
        c.extend = "Ext.grid.Panel"
        c.mixin :grid, :event_handling
        c.mixin :advanced_search if advanced_search_available
        c.mixin :edit_in_form if edit_in_form_available

        c.translate *%w[are_you_sure confirmation]

        # JavaScript includes
        ex = Netzke::Core.ext_path.join("examples")

        c.require ex.join("ux/CheckColumn.js")
        c.require :check_column_fix

        # Includes for column filters
        if column_filters_available
          [
            "ux/grid/menu/ListMenu.js",
            "ux/grid/menu/RangeMenu.js",
            "ux/grid/FiltersFeature.js"
          ].each{ |path| c.require(ex.join(path)) }

          %w{Boolean Date List Numeric String}.unshift("").each do |f|
            c.require(ex.join"ux/grid/filter/#{f}Filter.js")
          end
        end
      end

      # Allows children classes to simply do:
      #
      #     model "User"
      delegates_to_dsl :model

      def configure(c)
        # Defaults. The nil? checks are needed because these can be already set in a subclass
        c.enable_edit_in_form = self.class.edit_in_form_available if c.enable_edit_in_form.nil?
        c.enable_edit_inline = self.class.edit_inline_available if c.enable_edit_inline.nil?
        c.enable_extended_search = self.class.advanced_search_available if c.enable_extended_search.nil?
        c.enable_column_filters = self.class.column_filters_available if c.enable_column_filters.nil?
        c.enable_pagination = true if c.enable_pagination.nil?
        c.rows_per_page = 30 if c.rows_per_page.nil?
        c.tools = %w{ refresh } if c.tools.nil?

        super
      end

      def js_configure(c) #:nodoc:
        super

        c.title = c.title || self.class.js_config.properties[:title] || data_class.name.pluralize
        c.bbar = bbar
        c.context_menu = context_menu
        c.columns = final_columns(with_meta: true)
        c.columns_order = columns_order
        c.inline_data = get_data if c.load_inline_data
        c.pri = data_adapter.primary_key
      end

      def config
        @config ||= ActiveSupport::OrderedOptions.new.tap do |c|
          # extend with data_store convenient config object
          c.data_store = ActiveSupport::OrderedOptions.new
        end
      end

      def bbar
        config.has_key?(:bbar) ? config[:bbar] : default_bbar
      end

      def context_menu
        config.has_key?(:context_menu) ? config[:context_menu] : default_context_menu
      end

      # Override to change the default bottom toolbar
      def default_bbar
        res = config[:enable_edit_inline] || config[:enable_edit_in_form] ? %w{ add edit }.map(&:to_sym) : []
        res << :apply if config[:enable_edit_inline]
        res << :del
        res << "-" << :add_in_form << :edit_in_form if config[:enable_edit_inline] && config[:enable_edit_in_form]
        res << "-" << :search if config[:enable_extended_search]
        res
      end

      # Override to change the default context menu
      def default_context_menu
        res = config[:enable_edit_inline] || config[:enable_edit_in_form] ? [:edit] : []
        res << :del if !config[:read_only]
        res << "-" << :edit_in_form if config[:enable_edit_in_form] && config[:enable_edit_inline]
        res
      end

      action :add do |a|
        a.disabled = config[:prohibit_create]
        a.handler = "onAddInline" # overriding naming conventions as Ext 4 grid has its own onAdd method
        a.icon = :add
      end

      action :edit do |a|
        a.disabled = true
        a.handler = config[:enable_edit_inline] ? "onEdit" : "onEditInForm"
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

      action :add_in_form do |a|
        a.disabled = config[:prohibit_create]
        a.icon = :application_form_add
      end

      action :edit_in_form do |a|
        a.disabled = true
        a.icon = :application_form_edit
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

      def self.server_side_config_options
        super + [:scope]
      end

    end
  end
end
