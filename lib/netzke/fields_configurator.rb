module Netzke
  class FieldsConfigurator < GridPanel
    api :load_defaults

    def self.js_base_class
      GridPanel
    end
    
    def initialize(*args)
      super
      NetzkeAutoColumn.widget = config[:widget]
    end

    def default_config
      super.recursive_merge({
        :name              => 'columns',
        :widget_class_name => "GridPanel",
        :data_class_name   => "NetzkeAutoColumn",
        :persistent_layout => false,
        :persistent_config => false,
        :ext_config        => {:title => false}
      })
    end
    
    def actions
      super.merge(
        :defaults => {:text => 'Restore defaults'}
      )
    end
    
    def bbar
      super << "-" << "defaults"
    end
    
    def self.js_extend_properties
      super.merge({
        :get_commit_data => <<-JS.l,
          function(){
            return null; // because our commit data is already on the server side
          }
        JS
        :defaults => <<-JS.l,
          function(){
            Ext.Msg.confirm('Confirm', 'Are you sure?', function(btn){
              if (btn == 'yes') {
                this.loadDefaults();
              }
            }, this);
          }
        JS
      })
    end
    
    def load_defaults(params)
      config[:widget].persistent_config[:layout__columns] = config[:widget].default_db_fields
      NetzkeAutoColumn.rebuild_table
      {:load_store_data => get_data}
    end
   
    def commit(params)
      config[:widget].persistent_config[:layout__columns] = NetzkeAutoColumn.all_columns
      {}
    end
   
    # each time that we are loaded into the app, rebuild the table
    def before_load
      NetzkeAutoColumn.rebuild_table
    end
   
  end
end