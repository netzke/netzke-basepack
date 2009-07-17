require 'searchlogic'

module Netzke
  # GridPanel
  #
  # Functionality:
  # * data operations - get, post, delete, create
  # * column resize and move
  # * column hide
  # * permissions
  # * sorting
  # * pagination
  # * filtering
  # * properties and column configuration
  #
  # == Configuration
  # * <tt>:strong_default_attrs</tt> - a hash of attributes to be merged atop of every created/updated record.
  # * <tt>:scopes</tt> - an array of searchlogic-compatible scopes like this: ["user_id_not", user_id].
  # These scopes will be applied when records are searched for the grid.
  # * <tt>:ext_config[:config_tool]</tt> - enable configuration tool
  #
  # == TODO
  # * (optimization) come up with a way to not send default configuration values in js_config, 
  # as their number will grow with time
  class GridPanel < Base
    # Class-level configuration and its defaults
    def self.config
      set_default_config({
        :load_inline_data          => true,
        :filters_enabled           => true,
        :config_tool_enabled       => false,
        :column_move_enabled       => true,
        :column_hide_enabled       => true,
        :column_resize_enabled     => true,
        :persistent_layout_enabled => true,
        :persistent_config_enabled => true
      })
    end

    include Netzke::GridPanelExtras::JsBuilder
    include Netzke::GridPanelExtras::Api
    include Netzke::DbFields # database field operations

    # javascripts for grid-filtering (from Ext examples)
    if Netzke::GridPanel.config[:filters_enabled]
      js_include :ext_examples => %w{grid-filtering/menu/EditableItem.js grid-filtering/menu/RangeMenu.js grid-filtering/grid/GridFilters.js}
    
      js_include :ext_examples => %w{Boolean Date List Numeric String}.unshift("").map{|f| "grid-filtering/grid/filter/#{f}Filter.js" }
      
      js_include "#{File.dirname(__FILE__)}/grid_panel_extras/javascripts/filters.js"
    end
    
    # extra javascripts
    js_include "#{File.dirname(__FILE__)}/grid_panel_extras/javascripts/check-column.js"

    # define connection points between client side and server side of GridPanel. 
    # See implementation of equally named methods in the GridPanelExtras::Api module.
    api :get_data, :post_data, :delete_data, :resize_column, :move_column, :hide_column, :get_combo_box_options

    # widget type for DbFields
    # TODO: ugly, rethink
    def self.widget_type
      :grid
    end

    # default instance-level configuration
    def default_config
      {
        :ext_config => {
          :config_tool           => self.class.config[:config_tool_enabled],
          :enable_column_filters => self.class.config[:filters_enabled],
          :enable_column_move    => self.class.config[:column_move_enabled],
          :enable_column_hide    => self.class.config[:column_hide_enabled],
          :enable_column_resize  => self.class.config[:column_resize_enabled],
          :load_inline_data      => self.class.config[:load_inline_data]
        },
        :persistent_layout => self.class.config[:persistent_layout_enabled],
        :persistent_config => self.class.config[:persistent_config_enabled]
      }
    end

    def initial_dependencies
      ["FieldsConfigurator"] # TODO: make this happen automatically
    end

    def configuration_widgets
      res = []
      res << {
        :name              => 'columns',
        :widget_class_name => "FieldsConfigurator",
        :active            => true,
        :widget            => self
      } if config[:persistent_layout]

      res << {
        :name               => 'general',
        :widget_class_name  => "PropertyEditor",
        :widget_name        => id_name,
        :ext_config         => {:title => false}
      }
      
      res
    end

    def tools
      %w{ refresh }
    end

    def actions
      { :add    => {:text => 'Add',     :disabled => !@permissions[:create]},
        :edit   => {:text => 'Edit',    :disabled => !@permissions[:update]},
        :delete => {:text => 'Delete',  :disabled => !@permissions[:delete]},
        :apply  => {:text => 'Apply',   :disabled => !@permissions[:update] && !@permissions[:create]}
      }
    end

    def bbar
      persistent_config[:bottom_bar] ||= config[:bbar] == false ? nil : config[:bbar] || %w{ add edit apply delete }
    end

    def columns
      @columns ||= get_columns.convert_keys{|k| k.to_sym}
    end

    include ConfigurationTool # it will load ConfigurationPanel into a modal window
    
    protected
    
    def available_permissions
      %w(read update create delete)
    end

    def get_columns
      if config[:persistent_layout]
        persistent_config['layout__columns'] ||= default_db_fields
      else
        default_db_fields
      end
    end
    
  end
end