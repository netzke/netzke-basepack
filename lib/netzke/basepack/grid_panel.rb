require "netzke/basepack/grid_panel/columns"
require "netzke/basepack/grid_panel/services"
# require "netzke/basepack/plugins/configuration_tool"

module Netzke
  module Basepack
    # Ext.grid.EditorGridPanel-based component with the following features:
    #
    # * multi-line CRUD operations - get, post, delete, create
    # * (multe-record) editing and adding records through a form
    # * column resize, move and hide
    # * permissions
    # * sorting
    # * pagination
    # * filtering
    # * extended search
    # * (TODO) rows reordering (drag-n-drop)
    # * (TODO) dynamic configuration of properties and columns
    #
    # == Class configuration
    #
    # Configuration on this level is effective during the life-time of the application. The right place for setting these options are in
    # config/initializers, e.g.:
    #
    #     Netzke::GridPanel.column_filters_available = false
    #     Netzke::GridPanel.default_config = {:enable_config_tool => false}
    #
    # Most of these options influence the amount of JavaScript code that is generated for this component's class, in the way that
    # the less functionality is enabled, the less code is generated.
    #
    # The following configuration options are available:
    # * <tt>:column_filters_available</tt> - (default is true) include code for the filters in the column's context menu
    # * (TODO)<tt>:config_tool_available</tt> - (default is true) include code for the configuration tool that launches the configuration panel
    # * <tt>:edit_in_form_available</tt> - (defaults to true) include code for (multi-record) editing and adding records through a form
    # * <tt>:extended_search_available</tt> - (defaults to true) include code for extended configurable search
    # * <tt>:default_config</tt> - a hash of default configuration options for each instance of the GridPanel component.
    # See the "Instance configuration" section below.
    #
    # == Instance configuration
    # The following config options are available:
    # * <tt>:model</tt> - name of the ActiveRecord model that provides data to this GridPanel.
    # * <tt>:strong_default_attrs</tt> - a hash of attributes to be merged atop of every created/updated record.
    # * <tt>:scope</tt> - specifies how the data should be filtered.
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
    # * <tt>:enable_column_filters</tt> - enable filters in column's context menu
    # * <tt>:enable_edit_in_form</tt> - provide buttons into the toolbar that activate editing/adding records via a form
    # * <tt>:enable_extended_search</tt> - provide a button into the toolbar that shows configurable search form
    # * <tt>:enable_context_menu</tt> - enable rows context menu
    # * <tt>:enable_rows_reordering</tt> - enable reordering of rows with drag-n-drop; underlying model (specified in <tt>:model</tt>) must implement "acts_as_list"-compatible functionality; defaults to <tt>false</tt>
    # * <tt>:enable_pagination</tt> - enable pagination; defaults to <tt>true</tt>
    # * <tt>:rows_per_page</tt> - number of rows per page (ignored when <tt>:enable_pagination</tt> is set to <tt>false</tt>)
    # * <tt>:load_inline_data</tt> - load initial data into the grid right after its instantiation (saves a request to server); defaults to <tt>true</tt>
    # * (TODO) <tt>:mode</tt> - when set to <tt>:config</tt>, GridPanel loads in configuration mode
    # * <tt>:add/edit/multi_edit/search_form_config</tt> - additional configuration for add/edit/multi_edit/search form panel
    # * <tt>:add/edit/multi_edit_form_window_config</tt> - additional configuration for the window that wrapps up add/edit/multi_edit form panel
    # * <tt>:columns</tt> - an array of columns to be displayed in the grid; each column may be represented by a symbol (representing the model's attribute name), or a hash (when extra configuration is needed)
    #
    # == Columns
    # Columns are configured by passing an array to the +columns+ option. Each element in the array is either the name of model's (virtual) attribute, or a column configuration hash.
    # The column configuration hash recognizes the following options:
    #
    # * +name+ - name of the column, that may correspond to model's (virtual) attribute
    # * +read_only+ - a boolean that defines if the cells in the column should be editable
    # * +editable+ - same as +read_only+, but in reverse (takes precedence over +read_only+)
    # * +getter+ - a lambda that receives a record as a parameter, and is expected to return a string that will be printed in the cell (can be HTML code)
    # * +setter+ - a lambda that receives a record as first parameter, and the value passed from the cell as the second parameter, and is expected to modify the record accordingly
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
    # * +filterable+ - set to false to disable filtering on this column
    #
    # Besides these options, a column can receive any meaningful config option understood by Ext.grid.Column (http://dev.sencha.com/deploy/dev/docs/?class=Ext.grid.Column)
    #
    # == Actions
    # You can override GridPanel's actions to change their text, icons, and tooltips (see http://api.netzke.org/core/Netzke/Actions.html). You can also use these actions when configuring menus and toolbars.
    # GridPanel implements the following actions:
    # * +add+
    # * +del+
    # * +edit+
    # * +apply+
    # * +add_in_form+
    # * +edit_in_form+
    # * +search+
    #
    # == TODO
    # * Make ColumnModel pluggable (e.g. to easily replace it with Ext.ux.grid.LockingColumnModel)
    class GridPanel < Netzke::Base
      # Class-level configuration. These options directly influence the amount of generated
      # javascript code for this component's class. For example, if you don't want filters for the grid,
      # set column_filters_available to false, and the javascript for the filters won't be included at all.
      class_attribute :column_filters_available
      self.column_filters_available = true

      class_attribute :config_tool_available
      self.config_tool_available = true

      class_attribute :edit_in_form_available
      self.edit_in_form_available = true

      class_attribute :extended_search_available
      self.extended_search_available = true

      class_attribute :rows_reordering_available
      self.rows_reordering_available = true

      class_attribute :default_config
      self.default_config = {
        :enable_edit_in_form    => true,
        :enable_extended_search => true,
        :enable_column_filters  => true,
        :load_inline_data       => true,
        :enable_rows_reordering => false, # column drag n drop
        :enable_pagination      => true,
        :rows_per_page          => 25,
        :tools                  => %w{ refresh },
      }

      include self::Services
      include self::Columns

      include Netzke::Basepack::DataAccessor

      # def self.enforce_config_consistency
      #   default_config[:enable_edit_in_form]    &&= edit_in_form_available
      #   default_config[:enable_extended_search] &&= extended_search_available
      #   default_config[:enable_rows_reordering] &&= rows_reordering_available
      # end

      # def initialize(*args)
      #   # Deprecations
      #   config[:scopes] && ActiveSupport::Deprecation.warn(":scopes option is not effective any longer for GridPanel. Use :scope instead.")
      #
      #   super(*args)
      # end

      js_base_class "Ext.grid.EditorGridPanel"
      js_mixin :grid_panel
      js_mixin :advanced_search if extended_search_available
      js_mixin :edit_in_form if edit_in_form_available

      # I18n used in JavaScript
      js_property :i18n, {
        :are_you_sure => I18n.translate("netzke.basepack.generic.are_you_sure"),
        :confirm => I18n.translate("netzke.basepack.generic.confirm")
      }

      # Include extra javascript that we depend on
      def self.include_js
        res = []
        ext_examples = Netzke::Core.ext_location.join("examples")

        # Checkcolumn
        res << ext_examples.join("ux/CheckColumn.js")

        # Filters
        if column_filters_available
          res << ext_examples + "ux/gridfilters/menu/ListMenu.js"
          res << ext_examples + "ux/gridfilters/menu/RangeMenu.js"
          res << ext_examples + "ux/gridfilters/GridFilters.js"

          %w{Boolean Date List Numeric String}.unshift("").each do |f|
            res << ext_examples + "ux/gridfilters/filter/#{f}Filter.js"
          end

          # Fix
          res << "#{File.dirname(__FILE__)}/grid_panel/javascripts/misc.js"
        end

        # DD
        if rows_reordering_available
          res << "#{File.dirname(__FILE__)}/grid_panel/javascripts/rows-dd.js"
        end

        res
      end

      # Fields to be displayed in the "General" tab of the configuration panel
      def self.property_fields
        [
          # {:name => :ext_config__title,               :attr_type => :string},
          # {:name => :ext_config__header,              :attr_type => :boolean, :default => true},
          # {:name => :ext_config__enable_context_menu, :attr_type => :boolean, :default => true},
          # {:name => :ext_config__enable_pagination,   :attr_type => :boolean, :default => true},
          # {:name => :ext_config__rows_per_page,       :attr_type => :integer},
          # {:name => :ext_config__prohibit_create,     :attr_type => :boolean},
          # {:name => :ext_config__prohibit_update,     :attr_type => :boolean},
          # {:name => :ext_config__prohibit_delete,     :attr_type => :boolean},
          # {:name => :ext_config__prohibit_read,       :attr_type => :boolean}
        ]
      end


      # The result of this method (a hash) is converted to a JSON object and passed as the configuration parameter
      # to the constructor of our JavaScript class. Override it when you want to pass any extra configuration
      # to the JavaScript side.
      def js_config
        super.merge({
          :bbar => config.has_key?(:bbar) ? config[:bbar] : default_bbar,
          :context_menu => config.has_key?(:context_menu) ? config[:context_menu] : default_context_menu,
          :columns => columns(:with_meta => true), # columns
          :columns_order => config[:persistence] && state[:columns_order] || initial_columns_order,
          :model => config[:model], # the model name
          :inline_data => (get_data if config[:load_inline_data]), # inline data (loaded along with the grid panel)
          :pri => data_class.primary_key # table primary key name
        })
      end

      def get_association_values(record)
        columns.select{ |c| c[:name].index("__") }.each.inject({}) do |r,c|
          r.merge(c[:name] => record.value_for_attribute(c, true))
        end
      end

      def default_bbar
        res = %w{ add edit apply del }.map(&:to_sym).map(&:action)
        res << "-" << :add_in_form.action << :edit_in_form.action if config[:enable_edit_in_form]
        res << "-" << :search.action if config[:enable_extended_search]
        res
      end

      def default_context_menu
        res = %w{ edit del }.map(&:to_sym).map(&:action)
        res << "-" << :edit_in_form.action if config[:enable_edit_in_form]
        res
      end

      def configuration_components
        res = []
        res << {
          :persistent_config => true,
          :name              => 'columns',
          :class_name        => "FieldsConfigurator",
          :active            => true,
          :owner             => self
        }
        res << {
          :name               => 'general',
          :class_name  => "PropertyEditor",
          :component             => self,
          :title => false
        }
        res
      end

      action :add do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.add'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.add'),
          :disabled => config[:prohibit_create],
          :icon => :add
        }
      end

      action :edit, {
        :text => I18n.t('netzke.basepack.grid_panel.actions.edit'),
        :tooltip => I18n.t('netzke.basepack.grid_panel.actions.edit'),
        :disabled => true,
        :icon => :table_edit
      }

      action :del, {
        :text => I18n.t('netzke.basepack.grid_panel.actions.del'),
        :tooltip => I18n.t('netzke.basepack.grid_panel.actions.del'),
        :disabled => true,
        :icon => :table_row_delete
      }

      action :apply do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.apply'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.apply'),
          :disabled => config[:prohibit_update] && config[:prohibit_create],
          :icon => :tick
        }
      end

      action :add_in_form, {
        :text => I18n.t('netzke.basepack.grid_panel.actions.add_in_form'),
        :tooltip => I18n.t('netzke.basepack.grid_panel.actions.add_in_form'),
        :icon => :application_form_add
      }

      action :edit_in_form, {
        :text => I18n.t('netzke.basepack.grid_panel.actions.edit_in_form'),
        :tooltip => I18n.t('netzke.basepack.grid_panel.actions.edit_in_form'),
        :disabled => true,
        :icon => :application_form_edit
      }

      action :search, {
        :text => I18n.t('netzke.basepack.grid_panel.actions.search'),
        :tooltip => I18n.t('netzke.basepack.grid_panel.actions.search'),
        :enable_toggle => true,
        :icon => :find
      }

      component :add_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::GridPanel::RecordFormWindow",
          :title => "Add #{data_class.model_name.human}",
          :button_align => "right",
          :items => [{
            :class_name => "Netzke::Basepack::FormPanel",
            :model => config[:model],
            :items => default_fields_for_forms_with_default_values,
            :persistent_config => config[:persistent_config],
            :strong_default_attrs => config[:strong_default_attrs],
            :border => true,
            :bbar => false,
            :header => false,
            :mode => config[:mode],
            :record => data_class.new
          }.deep_merge(config[:add_form_config] || {})]
        }.deep_merge(config[:add_form_window_config] || {})
      end

      component :edit_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::GridPanel::RecordFormWindow",
          :title => "Edit #{data_class.model_name.human}",
          :button_align => "right",
          :items => [{
            :class_name => "Netzke::Basepack::FormPanel",
            :model => config[:model],
            :items => default_fields_for_forms,
            :persistent_config => config[:persistent_config],
            :bbar => false,
            :header => false,
            :mode => config[:mode]
            # :record_id gets assigned by deliver_component at the moment of loading
          }.deep_merge(config[:edit_form_config] || {})]
        }.deep_merge(config[:edit_form_window_config] || {})
      end

      component :multi_edit_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::GridPanel::RecordFormWindow",
          :title => "Edit #{data_class.model_name.human.pluralize}",
          :button_align => "right",
          :items => [{
            :class_name => "Netzke::Basepack::GridPanel::MultiEditForm",
            :model => config[:model],
            :items => default_fields_for_forms,
            :persistent_config => config[:persistent_config],
            :bbar => false,
            :header => false,
            :mode => config[:mode]
          }.deep_merge(config[:multi_edit_form_config] || {})]
        }.deep_merge(config[:multi_edit_form_window_config] || {})
      end

      component :search_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::GridPanel::SearchWindow",
          :model => config[:model],
          :fields => default_fields_for_forms
        }
      end


      # def search_panel
      #   {
      #     :class_name => "Netzke::Basepack::FormPanel",
      #     :model => "User",
      #     # :items => default_fields_for_forms,
      #     # :search_class_name => cronfig[:model],
      #     # :persistent_config => config[:persistent_config],
      #     :header => false,
      #     :bbar => false,
      #     # :mode => config[:mode]
      #   }
      # end

      # include ::Netzke::Plugins::ConfigurationTool if config_tool_available # it will load ConfigurationPanel into a modal window

    end
  end
end
