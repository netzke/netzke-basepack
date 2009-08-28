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
        # :widget_class_name => "GridPanel",
        :data_class_name   => "NetzkeAutoColumn",
        :persistent_config => false,
        :ext_config        => {
          :header => false,
          :enable_extended_search => false,
          :enable_edit_in_form => false
          # :bbar => super[:ext_config][:bbar] << "-" << "defaults"
        },
      })
    end
    
    def actions
      super.merge(
        :defaults => {:text => 'Restore defaults'}
      )
    end
    
    def independent_config
      res = super
      res[:ext_config][:bbar] = %w{ edit apply - defaults }
      res
    end
        
    def self.js_extend_properties
      {
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
      config[:widget].persistent_config[:layout__columns] = config[:widget].default_db_fields
      NetzkeAutoColumn.rebuild_table
      {:load_store_data => get_data, :reconfigure => js_config}
    end
   
    def commit(params)
      defaults_hash = config[:widget].class.config_columns.inject({}){ |r, c| r.merge!(c[:name] => c[:default]) }
      config[:widget].persistent_config[:layout__columns] = NetzkeAutoColumn.all_columns.map do |c| 
        c.reject!{ |k,v| defaults_hash[k.to_sym].to_s == v.to_s } # reject all keys that are same as defaults
        c = c["data_index"] || c["name"] if c.keys.count == 1 # denormalize the column
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