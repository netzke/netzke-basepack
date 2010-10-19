require "netzke/basepack/grid_panel/columns"
require "netzke/basepack/grid_panel/services"
require "netzke/basepack/grid_panel/javascript"
# require "netzke/basepack/plugins/configuration_tool"
# require "data_accessor"

module Netzke
  module Basepack
    # == GridPanel
    # Ext.grid.EditorGridPanel + server-side code
    #
    # == Features:
    # * multi-line CRUD operations - get, post, delete, create
    # * (multe-record) editing and adding records through a form
    # * column resize, move and hide
    # * permissions
    # * sorting
    # * pagination
    # * filtering
    # * extended configurable search
    # * rows reordering (drag-n-drop)
    # * dynamic configuration of properties and columns
    #
    # == Class configuration
    # Configuration on this level is effective during the life-time of the application. They can be put into a .rb file
    # inside of config/initializers like this:
    # 
    #     Netzke::GridPanel.column_filters_available = false
    #     Netzke::GridPanel.default_config = {:enable_config_tool => false}
    # 
    # Most of these options directly influence the amount of JavaScript code that is generated for this component's class.
    # The less functionality is enabled, the less code is generated.
    # 
    # The following configuration options are available:
    # * <tt>:column_filters_available</tt> - (default is true) include code for the filters in the column's context menu
    # * <tt>:config_tool_available</tt> - (default is true) include code for the configuration tool that launches the configuration panel
    # * <tt>:edit_in_form_available</tt> - (defaults to true) include code for (multi-record) editing and adding records through a form
    # * <tt>:extended_search_available</tt> - (defaults to true) include code for extended configurable search
    # * <tt>:default_config</tt> - a hash of default configuration options for each instance of the GridPanel component.
    # See the "Instance configuration" section below.
    # 
    # == Instance configuration
    # The following config options are available:
    # * <tt>:model</tt> - name of the ActiveRecord model that provides data to this GridPanel.
    # * <tt>:strong_default_attrs</tt> - a hash of attributes to be merged atop of every created/updated record.
    # * <tt>:query</tt> - specifies how the data should be filtered.
    #   When it's a symbol, it's used as a scope name. 
    #   When it's a string, it's a SQL statement (passed directly to +where+). 
    #   When it's a hash, it's a conditions hash (passed directly to +where+). 
    #   When it's an array, it's expanded into SQL statement with arguments (passed directly to +where+), e.g.:
    #   
    #     :query => ["id > ?", 100])
    # 
    #   When it's a Proc, it's passed the model class, and is expected to return a ActiveRecord::Relation, e.g.:
    # 
    #     :query => { |klass| klass.where(:id.gt => 100).order(:created_at) }  
    #     
    # * <tt>:enable_column_filters</tt> - enable filters in column's context menu
    # * <tt>:enable_edit_in_form</tt> - provide buttons into the toolbar that activate editing/adding records via a form
    # * <tt>:enable_extended_search</tt> - provide a button into the toolbar that shows configurable search form
    # * <tt>:enable_context_menu</tt> - enable rows context menu
    # * <tt>:enable_rows_reordering</tt> - enable reordering of rows with drag-n-drop; underlying model (specified in <tt>:model</tt>) must implement "acts_as_list"-compatible functionality; defaults to <tt>false</tt>
    # * <tt>:enable_pagination</tt> - enable pagination; defaults to <tt>true</tt>
    # * <tt>:rows_per_page</tt> - number of rows per page (ignored when <tt>:enable_pagination</tt> is set to <tt>false</tt>)
    # * <tt>:load_inline_data</tt> - load initial data into the grid right after its instantiation (saves a request to server); defaults to <tt>true</tt>
    # * <tt>:mode</tt> - when set to <tt>:config</tt>, GridPanel loads in configuration mode
    # * <tt>:add/edit/multi_edit/search_form_config</tt> - additional configuration for add/edit/multi_edit/search form panel
    # * <tt>:add/edit/multi_edit_form_window_config</tt> - additional configuration for the window that wrapps up add/edit/multi_edit form panel
    # 
    # Additionally supports Netzke::Base config options.
    # 
    # == Columns
    # Here's how the GridPanel decides which columns in which sequence and with which configuration to display.
    # First, the column configs are aquired from this GridPanel's persistent storage, as an array of hashes, each 
    # representing a column configuration, such as:
    #
    #   {:name => :created_at, :header => "Created", :tooltip => "When the record was created"}
    # 
    # This hash *overrides* (deep_merge) the hard-coded configuration, an example of which can be specifying 
    # columns for a GridPanel instance, e.g.:
    # 
    #   :columns => [{:name => :created_at, :sortable => false}]
    # 
    # ... which in its turn overrides the defaults provided by persistent storage managed by the AttributesConfigurator
    # that provides *model-level* (as opposed to a component-level) configuration of a database model 
    # (which is used by both grids and forms in Netzke).
    # And lastly, the defaults for AttributesConfigurator are calculated from the database model itself (extended by Netzke).
    # For example, in the model you can specify virtual attributes and their types that will be picked up by Netzke, the default
    # order of columns, or excluded columns. For details see <tt>Netzke::ActiveRecord::Attributes</tt>.
    #
    # Each column supports the option :sorting_scope, which defines a scope used for sorting the column. This option would be
    # useful for virtual columns for example. The scope will get one parameter which contains the direction (:asc or :desc)
    # Example:
    # { :name => complete_user_name, :sorting_scope => :sort_user_by_full_name }
    # class User < ActiveRecord::Base
    #     scope :sort_user_by_full_name, lambda { |dir|
    #         order("users.first_name #{dir.to_s}, users.last_name #{dir.to_s}")
    #     }
    # end
    # 
    # The columns are displayed in the order specified by what's found first in the following sequence:
    #   GridPanel instance's persistent storage
    #   hardcoded config
    #   AttributesConfigurator persistent storage
    #   netzke_expose_attributes in the database model
    #   database columns + (eventually) virtual attributes specified with netzke_attribute
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
      
      include self::Javascript
      include self::Services
      include self::Columns
    
      include Netzke::DataAccessor
      
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

      # Include extra javascript that we depend on
      def self.include_js
        res = ["#{File.dirname(__FILE__)}/grid_panel/javascripts/pre.js"]
      
        # Optional edit in form functionality
        res << "#{File.dirname(__FILE__)}/grid_panel/javascripts/edit_in_form.js" if edit_in_form_available
      
        # Optional extended search functionality
        res << "#{File.dirname(__FILE__)}/grid_panel/javascripts/advanced_search.js" if extended_search_available
      
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
    
    
      def default_bbar
        res = %w{ add edit apply del }.map(&:to_sym).map(&:action)
        res << "-" << :add_in_form.action << :edit_in_form.action if config[:enable_edit_in_form]
        res << "-" << :search.action if config[:enable_extended_search]
        # config[:enable_extended_search] && res << "-" << {
        #   :text => "Search", 
        #   :handler => :on_search, 
        #   :enable_toggle => true, 
        #   :icon => :find
        # }
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
          :text => I18n.t('netzke.basepack.grid_panel.add', :default => "Add"),
          :disabled => config[:prohibit_create],
          :icon => :add
        }
      end
      
      action :edit, {
        :text => I18n.t('netzke.basepack.grid_panel.edit', :default => "Edit"),
        :disabled => true,
        :icon => :table_edit
      }
      
      action :del, {
        :text => I18n.t('netzke.basepack.grid_panel.delete', :default => "Delete"),
        :disabled => true,
        :icon => :table_row_delete
      }
      
      action :apply do
        {
          :text => I18n.t('netzke.basepack.grid_panel.apply', :default => "Apply"),
          :disabled => config[:prohibit_update] && config[:prohibit_create],
          :icon => :tick
        }
      end
      
      action :add_in_form, {
        :text => I18n.t('netzke.basepack.grid_panel.add_in_form', :default => "Add in form"),
        :icon => :application_form_add
      }
      
      action :edit_in_form, {
        :text => I18n.t('netzke.basepack.grid_panel.edit_in_form', :default => "Edit in form"),
        :disabled => true,
        :icon => :application_form_edit
      }
      
      action :search, {
        :text => I18n.t('netzke.basepack.grid_panel.search', :default => "Search"),
        :enable_toggle => true, 
        :icon => :find
      }
      
      component :add_form do
        {
          :lazy_loading => true,
          :class_name => "Basepack::GridPanel::RecordFormWindow",
          :title => "Add #{data_class.table_name.singularize.humanize}",
          :button_align => "right",
          :items => [{
            :class_name => "Basepack::FormPanel",
            :model => config[:model],
            :items => default_fields_for_forms,
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
          :class_name => "Basepack::GridPanel::RecordFormWindow",
          :title => "Edit #{data_class.table_name.singularize.humanize}",
          :button_align => "right",
          :items => [{
            :class_name => "Basepack::FormPanel",
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
          :class_name => "Basepack::GridPanel::RecordFormWindow",
          :title => "Edit #{data_class.table_name.humanize}",
          :button_align => "right",
          :items => [{
            :class_name => "Basepack::GridPanel::MultiEditForm",
            :model => config[:model],
            :items => default_fields_for_forms,
            :persistent_config => config[:persistent_config],
            :bbar => false,
            :header => false,
            :mode => config[:mode]
          }.deep_merge(config[:multi_edit_form_config] || {})]
        }.deep_merge(config[:multi_edit_form_window_config] || {})
      end

      component :search_panel do
        {
          :lazy_loading => true,
          :class_name => "Basepack::GridPanel::SearchWindow",
          :model => config[:model],
          :fields => default_fields_for_forms
        }
      end
      
    
      # def search_panel
      #   {
      #     :class_name => "Basepack::FormPanel",
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