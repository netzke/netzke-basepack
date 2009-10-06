module Netzke
  # == FieldsConfigurator
  # Provides dynamic configuring columns/fields for GridPanel and FormPanel.
  # Configuration parameters:
  # * <tt>:widget</tt> - widget to configure columns/fields for
  class FieldsConfigurator < GridPanel
    api :load_defaults

    def initialize(*args)
      super
      NetzkeAutoColumn.widget = config[:widget]
    end

    def default_config
      super.deep_merge({
        :name              => 'columns',
        :data_class_name   => "NetzkeAutoColumn",
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
      %w{ edit apply - defaults }
    end
        
    def predefined_columns
      [{:name => :id}, *config[:widget].class.config_columns]
    end
        
    def self.js_extend_properties
      {
        # Disable the 'gear' tool for now
        :gear => <<-END_OF_JAVASCRIPT.l,
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
        
        :defaults => <<-END_OF_JAVASCRIPT.l,
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
      NetzkeAutoColumn.rebuild_table
      {:load_store_data => get_data, :reconfigure => js_config}
    end
   
    def commit(params)
      defaults_hash = config[:widget].class.config_columns.inject({}){ |r, c| r.merge!(c[:name] => c[:default]) }
      config[:widget].persistent_config[:layout__columns] = NetzkeAutoColumn.all_columns.map do |c| 
        # reject all keys that are 1) same as defaults, 2) 'position'
        c.reject!{ |k,v| defaults_hash[k.to_sym].to_s == v.to_s || k == 'position'} 
        c = c["name"] if c.keys.count == 1 # denormalize the column
        c
      end
      {}
    end
   
    # each time that we are loaded into the app, rebuild the table
    def before_load
      NetzkeAutoColumn.rebuild_table
    end
   
  end
end