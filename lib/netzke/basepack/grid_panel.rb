require "netzke/basepack/grid_panel/columns"
require "netzke/basepack/grid_panel/services"
# require "netzke/basepack/plugins/configuration_tool"

module Netzke
  module Basepack
    # Ext.grid.EditorGridPanel-based component with the following features:
    #
    # * ActiveRecord-model support with automatic column configuration
    # * multi-line CRUD operations - get, post, delete, create
    # * (multe-record) editing and adding records through a form
    # * persistent column resize, move and hide
    # * permissions
    # * sorting
    # * pagination
    # * filtering
    # * advanced search
    # * rows reordering by drag-n-drop, requires acts_as_list on the model
    # * virtual attribute support
    # * (TODO) dynamic configuration of properties and columns
    #
    # == Instance configuration
    # The following config options are supported:
    # * +model+ - name of the ActiveRecord model that provides data to this GridPanel, e.g. "User"
    # * +columns+ - an array of columns to be displayed in the grid; each column may be represented by a symbol (representing the model's attribute name), or a hash (when extra configuration is needed). See the "Columns" section below.
    # * +scope+ - specifies how the data should be filtered.
    #   When it's a symbol, it's used as a scope name.
    #   When it's a string, it's a SQL statement (passed directly to +where+).
    #   When it's a hash, it's a conditions hash (passed directly to +where+).
    #   When it's an array, it's expanded into an SQL statement with arguments (passed directly to +where+), e.g.:
    #
    #     :scope => ["id > ?", 100])
    #
    #   When it's a Proc, it's passed the model class, and is expected to return a ActiveRecord::Relation, e.g.:
    #
    #     :scope => { |rel| rel.where(:id.gt => 100).order(:created_at) }
    #
    # * +strong_default_attrs+ - (defaults to {}) a hash of attributes to be merged atop of every created/updated record, e.g. {:role_id => 1}
    # * +enable_column_filters+ - (defaults to true) enable filters in column's context menu
    # * +enable_edit_in_form+ - (defaults to true) provide buttons into the toolbar that activate editing/adding records via a form
    # * +enable_extended_search+ - (defaults to true) provide a button into the toolbar that shows configurable search form
    # * +enable_context_menu+ - (defaults to true) enable rows context menu
    # * +context_menu+ - an array of actions (e.g. [:edit, "-", :del] - see the Actions section) or +false+ to disable the context menu
    # * +enable_rows_reordering+ - (defaults to false) enable reordering of rows with drag-n-drop; underlying model (specified in +model+) must implement "acts_as_list"-compatible functionality
    # * +enable_pagination+ - (defaults to true) enable pagination
    # * +rows_per_page+ - (defaults to 30) number of rows per page (ignored when +enable_pagination+ is set to +false+)
    # * +load_inline_data+ - (defaults to true) load initial data into the grid right after its instantiation
    # * (TODO) +mode+ - when set to +config+, GridPanel loads in configuration mode
    # * <tt>[add|edit|multi_edit]_search_form_config</tt> - additional configuration for add/edit/multi_edit/search form panel
    # * <tt>[add|edit|multi_edit]_form_window_config</tt> - additional configuration for the window that wrapps up add/edit/multi_edit form panel
    #
    # == Columns
    # Columns are configured by passing an array to the +columns+ option. Each element in the array is either the name of model's (virtual) attribute (in which case the configuration will be fully automatic), or a hash that may contain the following configuration options as keys:
    #
    # * +name+ - (required) name of the column, that may correspond to the model's (virtual) attribute
    # * +read_only+ - a boolean that defines if the cells in the column should be editable
    # * +editable+ - same as +read_only+, but in reverse (takes precedence over +read_only+)
    # * +filterable+ - set to false to disable filtering on this column
    # * +getter+ - a lambda that receives a record as a parameter, and is expected to return a string that will be sent to the cell (can be HTML code), e.g.:
    #
    #     :getter => lambda {|r| [r.first_name, r.last_name].join }
    # * +setter+ - a lambda that receives a record as first parameter, and the value passed from the cell as the second parameter, and is expected to modify the record accordingly, e.g.:
    #
    #     :setter => lambda { |r,v| r.first_name, r.last_name = v.split(" ") }
    #
    # * +scope+ - the scope for one-to-many association column. Same syntax applies as for scoping out records for the grid itself. See "One-to-many association support" for details.
    #
    # * +sorting_scope+ - the name of the scope used for sorting the column. This can be useful for virtual columns for example. The scope will get one parameter specifying the direction (:asc or :desc). Example:
    #
    #     columns => [{ :name => "complete_user_name", :sorting_scope => :sort_user_by_full_name }, ...]
    #
    #     class User < ActiveRecord::Base
    #       scope :sort_user_by_full_name, lambda { |dir|
    #         order("users.first_name #{dir.to_s}, users.last_name #{dir.to_s}")
    #       }
    #     end
    #
    # * +format+ - the format to display data in case of date and datetime columns, e.g. 'Y-m-d g:i:s'.
    #
    # Besides these options, a column can receive any meaningful config option understood by Ext.grid.column.Column.
    #
    # == One-to-many association support
    # If the model bound to a grid +belongs_to+ another model, GridPanel can display an "assocition column" - where the user can select the associated record from a drop-down box. You can specify which method of the association should be used as the display value for the drop-down box options by using the double-underscore notation on the column name, where the association name is separated from the association method by "__" (double underscore). For example, let's say we have a Book that +belongs_to+ model Author, and Author responds to +first_name+. This way, the book grid can have a column defined as follows:
    #
    #     {:name => "author__first_name"}
    #
    # GridPanel will detect it to be an association column, and will use the drop-down box for selecting an author, where the list of authors will be represented by the author's first name.
    #
    # In order to scope out the records displayed in the drop-down box, the +scope+ column option can be used, e.g.:
    #
    #     {:name => "author__first_name", :scope => lambda{|relation| relation.where(:popular => true)}}
    #
    # == Add/edit/search forms
    # The forms will by default display the fields that correspond to the configured columns, taking over meaningful configuration options (e.g. +text+ will be converted into +fieldLabel+).
    # You may override the default fields displayed in the forms by overriding the +default_fields_for_forms+ method, which should return an array understood by the +items+ config property of the +FormPanel+. If you need to use a custom class instead of +FormPanel+, you may need to go an extra mile overriding the corresponding GridPanel's child component (e.g. "add_form" or "edit_form").
    #
    # == Actions
    # You can override GridPanel's actions to change their text, icons, and tooltips (see http://api.netzke.org/core/Netzke/Actions.html).
    #
    # GridPanel implements the following actions:
    # * +add+ - inline adding of a record
    # * +del+ - deletion of records
    # * +edit+ - inline editing of a record
    # * +apply+ - applying inline changes
    # * +add_in_form+ - adding a record in a form
    # * +edit_in_form+ - (multi-record) editing in a forrm
    # * +search+ - advanced searching
    #
    # == Class configuration
    #
    # Configuration on this level is effective during the life-time of the application. One place for setting these options are in application.rb, e.g.:
    #
    #     config.netzke.basepack.grid_panel.column_filters_available = false
    #
    # These can also be eventually set directly on the component's class:
    #
    #     Netzke::Basepack::GridPanel.column_filters_available = false
    #
    # Most of these options influence the amount of JavaScript code that is generated for this component's class, in the way that the less functionality is enabled, the less code is generated.
    #
    # The following class configuration options are available:
    # * +column_filters_available+ - (defaults to true) include code for the filters in the column's context menu
    # * (TODO) +config_tool_available+ - (defaults to true) include code for the configuration tool that launches the configuration panel
    # * +edit_in_form_available+ - (defaults to true) include code for (multi-record) editing and adding records through a form
    # * +extended_search_available+ - (defaults to true) include code for extended configurable search
    class GridPanel < Netzke::Base
      js_base_class "Ext.grid.Panel"

      class_attribute :columns_attr

      class_attribute :overridden_columns_attr
      self.overridden_columns_attr = {}

      # Class-level configuration. These options directly influence the amount of generated
      # javascript code for this component's class. For example, if you don't want filters for the grid,
      # set column_filters_available to false, and the javascript for the filters won't be included at all.
      class_config_option :column_filters_available, true

      class_config_option :extended_search_available, true

      class_config_option :edit_in_form_available, true

      class_config_option :rows_reordering_available, false

      class_config_option :config_tool_available, false

      class_config_option :default_instance_config, {
        :enable_edit_in_form    => edit_in_form_available,
        :enable_extended_search => extended_search_available,
        :enable_column_filters  => column_filters_available,
        :load_inline_data       => true,
        :enable_rows_reordering => false, # column drag n drop
        :enable_pagination      => true,
        :rows_per_page          => 30,
        :tools                  => %w{ refresh }
      }

      extend ActiveSupport::Memoizable

      include self::Services
      include self::Columns
      include Netzke::Basepack::DataAccessor

      js_mixin :grid_panel, :event_handling
      js_mixin :advanced_search if extended_search_available
      js_mixin :edit_in_form if edit_in_form_available

      js_translate *%w[are_you_sure confirmation]

      # JavaScript includes
      ex = Netzke::Core.ext_path.join("examples")

      js_include(ex.join("ux/CheckColumn.js"))
      js_include :check_column_fix

      # Includes for column filters
      if column_filters_available
        [
          "ux/grid/menu/ListMenu.js",
          "ux/grid/menu/RangeMenu.js",
          "ux/grid/FiltersFeature.js"
        ].each{ |path| js_include(ex.join(path)) }

        %w{Boolean Date List Numeric String}.unshift("").each do |f|
          js_include(ex.join"ux/grid/filter/#{f}Filter.js")
        end
      end

      # Includes for rows reordering
      if rows_reordering_available
        js_include(ex.join("#{File.dirname(__FILE__)}/grid_panel/javascripts/rows-dd.js"))
      end

      # Allows children classes to simply do
      #
      #     model "User"
      #
      # TODO: The rest of the list to be removed
      delegates_to_dsl :model, :add_form_config, :add_form_window_config, :edit_form_config, :edit_form_window_config, :multi_edit_form_config, :multi_edit_form_window_config

      # Inject some handy DSL methods into the child classes.
      def self.inherited(base)
        super

        base.class_eval do
          class << self
            def column(name, config = {})
              columns = self.columns_attr || []
              columns |= [config.merge(:name => name.to_s)]
              self.columns_attr = columns
            end

            def override_column(name, config)
              columns = self.overridden_columns_attr.dup
              self.overridden_columns_attr = columns.merge(name.to_sym => config)
            end
          end
        end
      end

      def configure
        super
        config.columns ||= self.columns_attr

        # user-passed :override_columns option should get deep_merged with the defaults
        config.override_columns = self.overridden_columns_attr.deep_merge(config.override_columns || {})
      end

      def js_config #:nodoc:
        res = super
        res.merge({
          :title => res[:title] || self.class.js_properties[:title] || data_class.name.pluralize,
          :bbar => config.has_key?(:bbar) ? config[:bbar] : default_bbar,
          :context_menu => config.has_key?(:context_menu) ? config[:context_menu] : default_context_menu,
          :columns => columns(:with_meta => true), # columns
          :columns_order => columns_order,
          :model => config[:model], # the model name
          :inline_data => (get_data if config[:load_inline_data]), # inline data (loaded along with the grid panel)
          :pri => data_class.primary_key # table primary key name
        })
      end

      def get_association_values(record) #:nodoc:
        columns.select{ |c| c[:name].index("__") }.each.inject({}) do |r,c|
          r.merge(c[:name] => record.value_for_attribute(c, true))
        end
      end

      def get_default_association_values #:nodoc:
        @_default_association_values ||= columns.select{ |c| c[:name].index("__") && c[:default_value] }.each.inject({}) do |r,c|
          assoc_name, assoc_method = c[:name].split '__'
          assoc_class = data_adapter.class_for(assoc_name)
          assoc_data_adapter = Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(assoc_class).new(assoc_class)
          assoc_instance = assoc_data_adapter.find_record c[:default_value]
          r.merge(c[:name] => assoc_instance.send(assoc_method))
        end
      end

      # Override to change the default bottom toolbar
      def default_bbar
        res = %w{ add edit apply del }.map(&:to_sym)
        res << "-" << :add_in_form << :edit_in_form if config[:enable_edit_in_form]
        res << "-" << :search if config[:enable_extended_search]
        res
      end

      # Override to change the default context menu
      def default_context_menu
        res = %w{ edit del }.map(&:to_sym)
        res << "-" << :edit_in_form if config[:enable_edit_in_form]
        res
      end

      action :add do |a|
        a.text = I18n.t('netzke.basepack.grid_panel.actions.add')
        a.tooltip = I18n.t('netzke.basepack.grid_panel.actions.add')
        a.disabled = config[:prohibit_create]
        a.handler = "onAddInline" # not following naming conventions here as Ext 4 grid has its own onAdd method
        a.icon = :add
      end

      action :edit do |a|
        a.text = I18n.t('netzke.basepack.grid_panel.actions.edit')
        a.tooltip = I18n.t('netzke.basepack.grid_panel.actions.edit')
        a.disabled = true
        a.icon = :table_edit
      end

      action :del do |a|
        a.text = I18n.t('netzke.basepack.grid_panel.actions.del')
        a.tooltip = I18n.t('netzke.basepack.grid_panel.actions.del')
        a.disabled = true
        a.icon = :table_row_delete
      end

      action :apply do |a|
        a.text = I18n.t('netzke.basepack.grid_panel.actions.apply')
        a.tooltip = I18n.t('netzke.basepack.grid_panel.actions.apply')
        a.disabled = config[:prohibit_update] && config[:prohibit_create]
        a.icon = :tick
      end

      action :add_in_form do |a|
        a.text = I18n.t('netzke.basepack.grid_panel.actions.add_in_form')
        a.tooltip = I18n.t('netzke.basepack.grid_panel.actions.add_in_form')
        a.icon = :application_form_add
      end

      action :edit_in_form do |a|
        a.text = I18n.t('netzke.basepack.grid_panel.actions.edit_in_form')
        a.tooltip = I18n.t('netzke.basepack.grid_panel.actions.edit_in_form')
        a.disabled = true
        a.icon = :application_form_edit
      end

      action :search do |a|
        a.text = I18n.t('netzke.basepack.grid_panel.actions.search')
        a.tooltip = I18n.t('netzke.basepack.grid_panel.actions.search')
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
        c.form_config.multi_edit = true
      end

      component :search_window do |c|
        c.klass = SearchWindow
        c.model = config.model
        c.fields = default_fields_for_forms
      end

    private

      def preconfigure_record_window(c)
        c.klass = RecordFormWindow

        c.form_config = ActiveSupport::OrderedOptions.new.tap do |f|
          f.model = config[:model]
          f.persistent_config = config[:persistent_config]
          f.strong_default_attrs = config[:strong_default_attrs]
          f.mode = config[:mode]
        end
      end

    end
  end
end
