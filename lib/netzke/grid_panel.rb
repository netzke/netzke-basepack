require 'searchlogic'
require "app/models/netzke_grid_panel_column"

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
    # Class-level configuration with defaults
    def self.config
      set_default_config({
        :column_manager => "NetzkeGridPanelColumn",
        :enable_filters => false
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
    interface :get_data, :post_data, :delete_data, :resize_column, :move_column, :get_cb_choices

    # widget type for DbFields
    # TODO: ugly, rethink
    def self.widget_type
      :grid
    end

    def self.column_manager_class
      config[:column_manager].constantize
    rescue
      nil
    end

    def column_manager_class
      self.class.column_manager_class
    end

    # default instance-level configuration
    def initial_config
      {
        :ext_config => {
          :config_tool           => true,
          :enable_column_filters => Netzke::GridPanel.config[:enable_filters],
          :enable_column_move    => true,
          :enable_column_resize  => true
        },
        :persistent_layout => true,
        :persistent_config => true
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
        :ext_config        => {:title => false},
        :active            => true,
        :layout            => NetzkeLayout.by_widget(id_name)
      } if config[:persistent_layout]

      res << {
        :name               => 'general',
        :widget_class_name  => "PropertyEditor",
        :widget_name   => id_name,
        :ext_config         => {:title => false}
      }
      
      res
    end

    # get columns from layout manager
    def get_columns
      @columns ||=
      if config[:persistent_layout] && layout_manager_class && column_manager_class
        layout = layout_manager_class.by_widget(id_name)
        layout ||= column_manager_class.create_layout_for_widget(self)
        layout.items_arry
      else
        default_db_fields
      end
    end
    
    def tools
      %w{ refresh }
    end

    def actions
      { :add    => {:text => 'Add', :disabled => !@permissions[:create]},
        :edit   => {:text => 'Edit', :disabled => !@permissions[:update]},
        :delete => {:text => 'Delete', :disabled => !@permissions[:delete]},
        :apply  => {:text => 'Apply', :disabled => !@permissions[:update] && !@permissions[:create]}
      }
    end

    def bbar
      persistent_config[:bottom_bar] ||= config[:bbar] == false ? nil : config[:bbar] || %w{ add edit apply delete }
    end
    
    include ConfigurationTool # it will load aggregation with name :properties into a modal window
    
    protected
    
    def available_permissions
      %w(read update create delete)
    end
    
  end
end