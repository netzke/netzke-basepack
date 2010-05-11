module Netzke
  # == FieldsConfigurator
  # Provides dynamic configuring columns/fields for GridPanel and FormPanel.
  # Configuration parameters:
  # * <tt>:widget</tt> - widget to configure columns/fields for
  class FieldsConfigurator < GridPanel
    api :load_defaults

    def initialize(*args)
      super
      @auto_table_klass = is_for_grid? ? NetzkeAutoColumn : NetzkeAutoField
      @auto_table_klass.widget = client_widget
    end

    # widget that uses us
    def client_widget
      @passed_config[:widget]
    end

    # is our client widget a grid (as opposed to a form)?
    def is_for_grid?
      client_widget.class.ancestors.include?(GridPanel)
    end

    def default_config
      super.deep_merge({
        :name              => 'columns',
        :model   => is_for_grid? ? "NetzkeAutoColumn" : "NetzkeAutoField",
        :ext_config        => {
          :header => false,
          :enable_extended_search => false,
          :enable_edit_in_form => false,
          :enable_rows_reordering => GridPanel.config[:rows_reordering_available],
          :enable_pagination => false
        },
      })
    end
    
    def actions
      super.merge(
        :defaults => {:text => 'Restore defaults'}
      )
    end
    
    def default_bbar
      %w{ add edit apply del - defaults }
    end
        
    def predefined_columns
      [{:name => :id}, *config[:widget].class.config_columns]
    end
        
    def self.js_extend_properties
      {
        # Disable the 'gear' tool for now
        :on_gear => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.feedback("You can't configure configurator (yet)");
          }
        END_OF_JAVASCRIPT
        
        # we need to provide this function so that the server-side commit would happen
        :get_commit_data => <<-END_OF_JAVASCRIPT.l,
          function(){
            return null; // because our commit data is already at the server
          }
        END_OF_JAVASCRIPT
        
        :on_defaults => <<-END_OF_JAVASCRIPT.l,
          function(){
            Ext.Msg.confirm('Confirm', 'Are you sure?', function(btn){
              if (btn == 'yes') {
                this.loadDefaults();
              }
            }, this);
          }
        END_OF_JAVASCRIPT
      }
    end
    
    def load_defaults(params)
      config[:widget].persistent_config[:layout__columns] = config[:widget].default_columns
      @auto_table_klass.rebuild_table
      {:load_store_data => get_data}
    end
   
    def commit(params)
      defaults_hash = config[:widget].class.config_columns.inject({}){ |r, c| r.merge!(c[:name] => c[:default]) }
      config[:widget].persistent_config[:layout__columns] = @auto_table_klass.all_columns.map do |c| 
        # reject all keys that are 1) same as defaults, 2) 'position'
        c.reject!{ |k,v| defaults_hash[k.to_sym].to_s == v.to_s || k == 'position'} 
        c = c["name"] if c.keys.size == 1 # denormalize the column
        c
      end
      {}
    end
   
    # each time that we are loaded into the app, rebuild the table
    def before_load
      @auto_table_klass.rebuild_table
    end
   
    # Don't show the config tool
    def config_tool_needed?
      false
    end
   
  end
end