require 'searchlogic'

module Netzke
  #
  # GridPanel
  #
  # Functionality:
  # * data operations - get, post, delete, create
  # * column resize and move
  # * column hide - TODO
  # * permissions
  # * sorting
  # * pagination
  # * filtering
  # * properties and column configuration
  #
  class GridPanel < Base
    # Class-level configuration and its defaults
    def self.config
      set_default_config({
        :enable_filters                       => true,
        :config_tool_enabled_by_default       => false,
        :column_move_enabled_by_default       => true,
        :column_hide_enabled_by_default       => true,
        :column_resize_enabled_by_default     => true,
        :persistent_layout_enabled_by_default => true,
        :persistent_config_enabled_by_default => true
      })
    end

    include Netzke::GridPanelExtras::JsBuilder
    include Netzke::GridPanelExtras::Interface
    include Netzke::DbFields # database field operations

    # javascripts for grid-filtering (from Ext examples)
    if Netzke::GridPanel.config[:enable_filters]
      js_include :ext_examples => %w{grid-filtering/menu/EditableItem.js grid-filtering/menu/RangeMenu.js grid-filtering/grid/GridFilters.js}
    
      js_include :ext_examples => %w{Boolean Date List Numeric String}.unshift("").map{|f| "grid-filtering/grid/filter/#{f}Filter.js" }
      
      js_include "#{File.dirname(__FILE__)}/grid_panel_extras/javascripts/filters.js"
    end
    
    # extra javascripts
    js_include "#{File.dirname(__FILE__)}/grid_panel_extras/javascripts/check-column.js"

    # define connection points between client side and server side of GridPanel. 
    # See implementation of equally named methods in the GridPanelExtras::Interface module.
    interface :get_data, :post_data, :delete_data, :resize_column, :move_column, :hide_column, :get_cb_choices

    # widget type for DbFields
    # TODO: ugly, rethink
    def self.widget_type
      :grid
    end

    # default instance-level configuration
    def initial_config
      {
        :ext_config => {
          :config_tool           => self.class.config[:config_tool_enabled_by_default],
          :enable_column_filters => self.class.config[:enable_filters],
          :enable_column_move    => self.class.config[:column_move_enabled_by_default],
          :enable_column_hide    => self.class.config[:column_hide_enabled_by_default],
          :enable_column_resize  => self.class.config[:column_resize_enabled_by_default]
        },
        :persistent_layout => self.class.config[:persistent_layout_enabled_by_default],
        :persistent_config => self.class.config[:persistent_config_enabled_by_default]
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
        :widget            => self,
        :persistent_layout => true
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
      @columns ||= get_columns
    end
    
    include ConfigurationTool # it will load aggregation with name :properties into a modal window
    
    protected
    
    def available_permissions
      %w(read update create delete)
    end

    def get_columns
      if config[:persistent_layout]
        NetzkeLayoutItem.widget = id_name
        NetzkeLayoutItem.data = default_db_fields if NetzkeLayoutItem.all.empty?
        NetzkeLayoutItem.all
      else
        default_db_fields
      end
    end
    
  end
end