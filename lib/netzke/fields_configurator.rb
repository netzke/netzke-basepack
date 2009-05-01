module Netzke
  class FieldsConfigurator < GridPanel
    interface :load_defaults

    def self.js_base_class
      GridPanel
    end
    
    def initialize(*args)
      super

      NetzkeLayoutItem.widget      = config[:widget].id_name
      config[:data_class_name]     = "NetzkeLayoutItem"
    end

    def initial_config
      super.recursive_merge({
        :name              => 'columns',
        :widget_class_name => "GridPanel"
        # :ext_config        => {:title => false}
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
        :defaults => <<-JS.l,
          function(){
            Ext.Msg.confirm('Confirm', 'Are you sure?', function(btn){
              if (btn == 'yes') {
                Ext.Ajax.request({
                  url:this.initialConfig.interface.loadDefaults,
                  callback:function(){
                    this.store.reload();
                  },
                  scope:this
                })
              }
            }, this);
          }
        JS
      })
    end
    
    def load_defaults(params)
      persistent_config.for_widget(config[:widget].id_name){ |p| p[:layout__columns] = config[:widget].default_db_fields }
      # NetzkeLayoutItem.data = config[:widget].default_db_fields
      {}
    end
    
    def default_db_fields_with_widget_change
      NetzkeLayoutItem.widget = config[:widget].id_name
      res = default_db_fields_without_widget_change
      NetzkeLayoutItem.widget = id_name
      res
    end
    
    alias_method_chain :default_db_fields, :widget_change
    
    # def get_columns
    #   if config[:persistent_layout]
    #     db_fields = default_db_fields
    #     NetzkeLayoutItem.widget = id_name
    #     NetzkeLayoutItem.data = db_fields if NetzkeLayoutItem.all.empty?
    #     NetzkeLayoutItem.widget = config[:widget]
    #     NetzkeLayoutItem.all
    #   else
    #     default_db_fields
    #   end
    # end
        
  end
end