require 'searchlogic'
module Netzke
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
    include_extras(__FILE__)

    # define connection points between client side and server side of GridPanel. See implementation of equally named methods in the GridPanelInterface module.
    interface :get_data, :post_data, :delete_data, :resize_column, :move_column, :get_cb_choices

    include Netzke::DbFields

    module ClassMethods
      def widget_type
        :grid
      end

      # Global GridPanel configuration
      def config
        set_default_config({
            :column_manager => "NetzkeGridPanelColumn"
        })
      end

      def column_manager_class
        config[:column_manager].constantize
      rescue
        nil
      end
    end
    extend ClassMethods

    def layout_manager_class
      self.class.layout_manager_class
    end

    def column_manager_class
      self.class.column_manager_class
    end

    # default grid configuration
    def initial_config
      {
        :ext_config => {
          :config_tool           => false,
          :enable_column_filters => Netzke::Base.config[:grid_panel][:filters],
          :enable_column_move    => true,
          :enable_column_resize  => true,
          :load_mask             => true
        },
        :persistent_layout => true,
        :persistent_config => true
      }
    end

    def initial_dependencies
      ["FieldsConfigurator"] # TODO: make this happen automatically
    end

    def property_widgets
      [{
        :name              => 'columns',
        :widget_class_name => "FieldsConfigurator",
        :ext_config        => {:title => false},
        :active            => true,
        :layout            => NetzkeLayout.by_widget(id_name)
      },{
        :name               => 'general',
        :widget_class_name  => "PreferenceGrid",
        :host_widget_name   => id_name,
        :default_properties => available_permissions.map{ |k| {:name => "permissions.#{k}", :value => @permissions[k.to_sym]}},
        :ext_config         => {:title => false}
      }]
    end

    def properties__general__load_source(params = {})
      w = aggregatee_instance(:properties__general)
      w.interface_load_source(params)
    end

    protected
    
    def available_permissions
      %w(read update create delete)
    end

    public

    # get columns from layout manager
    def get_columns
      @columns ||=
      if config[:persistent_layout] && layout_manager_class && column_manager_class
        layout = layout_manager_class.by_widget(id_name)
        layout ||= column_manager_class.create_layout_for_widget(self)
        layout.items_hash  # TODO: bad name!
      else
        default_db_fields
      end
    end
    
    def tools
      [{:id => 'refresh', :on => {:click => 'refreshClick'}}]
    end

    def actions
      [{
        :text => 'Add', :handler => 'add', :disabled => !@permissions[:create]
      },{
        :text => 'Edit', :handler => 'edit', :disabled => !@permissions[:update]
      },{
        :text => 'Delete', :handler => 'delete', :disabled => !@permissions[:delete]
      },{
        :text => 'Apply', :handler => 'submit', :disabled => !@permissions[:update] && !@permissions[:create]
      }]
    end

    

    # Uncomment to enable a menu duplicating the actions
    # def js_menus
    #   [{:text => "config.dataClassName".l, :menu => "config.actions".l}]
    # end
    
    include PropertiesTool # it will load aggregation with name :properties into a modal window
  end
end