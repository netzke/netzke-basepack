module Netzke
  class FieldsConfigurator < GridPanel
    interface :load_defaults

    def self.js_base_class
      GridPanel
    end
    
    def initialize(*args)
      super

      config[:conditions]         = {:layout_id => config[:layout].id}
      config[:data_class_name]    = config[:layout].items_class
      # config[:persistent_layout]  = false
    end

    def initial_config
      super.recursive_merge({
        :name              => 'columns',
        :widget_class_name => "GridPanel",
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
      NetzkeLayout.destroy(config[:layout].id)
      config[:data_class_name].constantize.create_layout_for_widget(parent.parent)
      {}
    end
    
  end
end