require "netzke/grid_panel/grid_panel_js"
require "netzke/grid_panel/grid_panel_api"
require "netzke/plugins/configuration_tool"
require "netzke/data_accessor"

module Netzke
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
  #     Netzke::GridPanel.configure :column_filters_available, false
  #     Netzke::GridPanel.configure :default_config => {:ext_config => {:enable_config_tool => false}}
  # 
  # Most of these options directly influence the amount of JavaScript code that is generated for this widget's class.
  # The less functionality is enabled, the less code is generated.
  # 
  # The following configuration options are available:
  # * <tt>:column_filters_available</tt> - (default is true) include code for the filters in the column's context menu
  # * <tt>:config_tool_available</tt> - (default is true) include code for the configuration tool that launches the configuration panel
  # * <tt>:edit_in_form_available</tt> - (defaults to true) include code for (multi-record) editing and adding records through a form
  # * <tt>:extended_search_available</tt> - (defaults to true) include code for extended configurable search
  # * <tt>:default_config</tt> - a hash of default configuration options for each instance of the GridPanel widget.
  # See the "Instance configuration" section below.
  # 
  # == Instance configuration
  # The following config options are available:
  # * <tt>:model</tt> - name of the ActiveRecord model that provides data to this GridPanel.
  # * <tt>:strong_default_attrs</tt> - a hash of attributes to be merged atop of every created/updated record.
  # * <tt>:scopes</tt> - an array of named scopes to filter grid data, e.g.:
  #     
  #     [["user_id_not", 100], ["name_like", "Peter"]]
  # 
  # In the <tt>:ext_config</tt> hash (see Netzke::Base) the following GridPanel specific options are available:
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
  # 
  # Additionally supports Netzke::Base config options.
  # 
  # == Column
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
  # that provides *model-level* (as opposed to a widget-level) configuration of a database model 
  # (which is used by both grids and forms in Netzke).
  # And lastly, the defaults for AttributesConfigurator are calculated from the database model itself, powered by Netzke.
  # For example, in the model you can specify virtual attributes and their types that will be picked up by Netzke, the default
  # order of columns, or excluded columns. For details see <tt>Netzke::ActiveRecord::Attributes</tt>.
  # 
  # The columns are displayed in the order specified by what's found first in the following sequence:
  #   GridPanel instance's persistent storage
  #   hardcoded config
  #   AttributesConfigurator persistent storage
  #   netzke_expose_attributes in the database model
  #   database columns + (eventually) virtual attributes specified with netzke_virtual_attribute
  class GridPanel < Base
    # javascript (client-side)
    include GridPanelJs
    
    # API (server-side)
    include GridPanelApi
    
    # Columns
    include GridPanelColumns
    
    # Code shared between GridPanel, FormPanel, and other widgets that serve as interface to database tables
    include Netzke::DataAccessor
    

    def self.enforce_config_consistency
      config[:default_config][:ext_config][:enable_edit_in_form]    &&= config[:edit_in_form_available]
      config[:default_config][:ext_config][:enable_extended_search] &&= config[:extended_search_available]
      config[:default_config][:ext_config][:enable_rows_reordering] &&= config[:rows_reordering_available]
    end

    # Class-level configuration. This options directly influence the amount of generated
    # javascript code for this widget's class. For example, if you don't want filters for the grid, 
    # set :column_filters_available to false, and the javascript for the filters won't be included at all.
    def self.config
      set_default_config({
        
        :column_filters_available     => true,
        :config_tool_available        => true,
        :edit_in_form_available       => true,
        :extended_search_available    => true,
        :rows_reordering_available    => true,
        
        :default_config => {
          :ext_config => {
            :enable_edit_in_form    => true,
            :enable_extended_search => true,
            :enable_column_filters  => true,
            :load_inline_data       => true,
            :enable_context_menu    => true,
            :enable_rows_reordering => false, # column drag n drop
            :enable_pagination      => true,
            :rows_per_page          => 25,
            :tools                  => %w{ refresh },
            
            :mode                   => :normal # when set to :config, :configuration button is enabled
          },
          :persistent_config      => true
          
        }
      })
    end

    # Include extra javascript that we depend on
    def self.include_js
      res = []
      
      # Checkcolumn
      ext_examples = Netzke::Base.config[:ext_location] + "/examples/"
      res << ext_examples + "ux/CheckColumn.js"
      
      # Filters
      if config[:column_filters_available]
        ext_examples = Netzke::Base.config[:ext_location] + "/examples/"
        res << ext_examples + "ux/gridfilters/menu/ListMenu.js"
        res << ext_examples + "ux/gridfilters/menu/RangeMenu.js"
        res << ext_examples + "ux/gridfilters/GridFilters.js"
      
        %w{Boolean Date List Numeric String}.unshift("").each do |f|
          res << ext_examples + "ux/gridfilters/filter/#{f}Filter.js"
        end
        
      end
      
      # DD
      if config[:rows_reordering_available]
        res << "#{File.dirname(__FILE__)}/grid_panel/javascripts/rows-dd.js"
      end

      res
    end
    
    # Define connection points between client side and server side of GridPanel. 
    # See implementation of equally named methods in the GridPanelApi module.
    api :get_data, :post_data, :delete_data, :resize_column, :move_column, :hide_column, :get_combobox_options, :move_rows
    
    # Edit in form
    api :create_new_record if config[:edit_in_form_available]

    # (We can't memoize this method because at some point we extend it, e.g. in Netzke::DataAccessor)
    def data_class
      ::ActiveSupport::Deprecation.warn("data_class_name option is deprecated. Use model instead", caller) if config[:data_class_name]
      model_name = config[:model] || config[:data_class_name]
      @data_class ||= model_name.nil? ? raise(ArgumentError, "No model specified for widget #{global_id}") : model_name.constantize
    end
    
    def initialize(config = {}, parent = nil)
      super

      apply_helpers
    end


    
    # Fields to be displayed in the "General" tab of the configuration panel
    def self.property_fields
      res = [
        {:name => :ext_config__title,               :type => :string},
        {:name => :ext_config__header,              :type => :boolean, :default => true},
        {:name => :ext_config__enable_context_menu, :type => :boolean, :default => true},
        # {:name => :ext_config__context_menu,        :type => :json},
        {:name => :ext_config__enable_pagination,   :type => :boolean, :default => true},
        {:name => :ext_config__rows_per_page,       :type => :integer},
        # {:name => :ext_config__bbar,                :type => :json},
        {:name => :ext_config__prohibit_create,     :type => :boolean},
        {:name => :ext_config__prohibit_update,     :type => :boolean},
        {:name => :ext_config__prohibit_delete,     :type => :boolean},
        {:name => :ext_config__prohibit_read,       :type => :boolean}
      ]
      
      # res << {:name => :ext_config__enable_extended_search, :type => :boolean} if config[:extended_search_available]
      # res << {:name => :ext_config__enable_edit_in_form, :type => :boolean} if config[:edit_in_form_available]
      
      # TODO: a buggy thing
      # res << {:name => :layout__columns,                 :type => :json}
      
      res
      
    end
    
    def default_config
      res = super
      
      res[:ext_config][:bbar] = default_bbar
      res[:ext_config][:context_menu] = default_context_menu
      
      res
    end
    
    def default_bbar
      res = %w{ add edit apply del }
      res << "-" << "add_in_form" << "edit_in_form" if self.class.config[:edit_in_form_available]
      res << "-" << "search" if self.class.config[:extended_search_available]
      res
    end
    
    def default_context_menu
      res = %w{ edit del }
      res << "-" << "edit_in_form" if self.class.config[:edit_in_form_available]
      res
    end
    
    def configuration_widgets
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
        :widget             => self,
        :ext_config         => {:title => false}
      }
      res
    end

    def actions
      # Defaults
      { 
        :add          => {:text => 'Add',     :disabled      => ext_config[:prohibit_create]},
        :edit         => {:text => 'Edit',    :disabled      => true},
        :del          => {:text => 'Delete',  :disabled      => true},
        :apply        => {:text => 'Apply',   :disabled      => ext_config[:prohibit_update] && ext_config[:prohibit_create]},
        :add_in_form  => {:text => 'Add in form', :disabled  => !ext_config[:enable_edit_in_form]},
        :edit_in_form => {:text => 'Edit in form', :disabled => true},
        :search       => {:text => 'Search', :disabled       => !ext_config[:enable_extended_search], :checked => true}
      }
    end

    def initial_late_aggregatees
      res = {}
      
      # Edit in form
      res.merge!({
        :add_form => {
          :class_name => "GridPanel::RecordFormWindow",
          :ext_config => {
            :title => "Add #{data_class.name.humanize}",
            :button_align => "right"
          },
          :item => {
            :class_name => "FormPanel",
            :model => data_class.name,
            :persistent_config => config[:persistent_config],
            :strong_default_attrs => config[:strong_default_attrs],
            :ext_config => {
              :border => true,
              :bbar => false,
              :header => false,
              :mode => ext_config[:mode]
            },
            :record => data_class.new
          }
        },
        # :edit_form => {
        #   :class_name => "GridPanel::RecordFormWindow",
        #   :ext_config => {
        #     :title => "Edit #{data_class.name.humanize}",
        #     :button_align => "right"
        #   },
        #   :item => {
        #     :class_name => "FormPanel",
        #     :model => data_class.name,
        #     :persistent_config => config[:persistent_config],
        #     :ext_config => {
        #       :bbar => false,
        #       :header => false,
        #       :mode => ext_config[:mode]
        #     }
        #   },
        # },
        
        :edit_form => {
          :class_name => "FormPanel",
          :model => data_class.name,
          :persistent_config => config[:persistent_config],
          :ext_config => {
            :bbar => false,
            :header => false,
            :mode => ext_config[:mode]
          }
        },
        
        :multi_edit_form => {
          :class_name => "FormPanel",
          :model => data_class.name,
          :persistent_config => config[:persistent_config],
          :ext_config => {
            :bbar => false,
            :header => false,
            :mode => ext_config[:mode]
          }
        },
        
        :new_record_form => {
          :class_name => "FormPanel",
          :model => data_class.name,
          :persistent_config => config[:persistent_config],
          :strong_default_attrs => config[:strong_default_attrs],
          :ext_config => {
            :bbar => false,
            :header => false,
            :mode => ext_config[:mode]
          },
          :record => data_class.new
        }
      }) if ext_config[:enable_edit_in_form]
      
      # Extended search
      res.merge!({
        :search_panel => {
          :class_name => "SearchPanel",
          :search_class_name => data_class.name,
          :persistent_config => config[:persistent_config],
          :ext_config => {
            :header => false, 
            :bbar => false, 
            :mode => ext_config[:mode]
          },
        }
      }) if ext_config[:enable_extended_search]
      
      res
    end

    include Plugins::ConfigurationTool if config[:config_tool_available] # it will load ConfigurationPanel into a modal window
    
  end
end