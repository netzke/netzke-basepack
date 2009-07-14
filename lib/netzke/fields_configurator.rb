module Netzke
  class FieldsConfigurator < GridPanel
    api :load_defaults

    def self.js_base_class
      GridPanel
    end
    
    def initialize(*args)
      super
      AutoColumn.widget = config[:widget]
    end

    def initial_config
      super.recursive_merge({
        :name              => 'columns',
        :widget_class_name => "GridPanel",
        :data_class_name   => "AutoColumn",
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
      persistent_config.for_widget(config[:widget].id_name){ |p| 
        p[:layout__columns] = config[:widget].default_db_fields 
      }
      # NetzkeLayoutItem.data = config[:widget].default_db_fields
      {:this => {:load_store_data => get_data}}
    end
   
    def commit(params)
      # directly access self.class.persistent_config
      self.class.persistent_config.for_widget(config[:widget].id_name) do |p|
        p[:layout__columns] = AutoColumn.all.map(&:attributes)
      end
      {}
    end
   
    def cancel
      AutoColumn.reset
    end
  end
end