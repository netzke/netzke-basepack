module Netzke
  class FieldsConfigurator < GridPanel
    interface :load_defaults
    
    def initialize(*args)
      super

      # process config[:layout]
      config[:conditions] = {:layout_id => (config[:layout] && config[:layout].id)}
      config[:columns] = [
        :id, 
        :label, 
        {:name => :read_only, :label => "R/O"}, 
        :hidden, 
        {:name => :width, :width => 50}, 
        {:name => :editor, :editor => :combo_box},
        {:name => :renderer, :editor => :combo_box}
      ]
      
    end

    def initial_config
      super.recursive_merge({
        :name              => 'columns',
        :widget_class_name => "GridPanel",
        :data_class_name   => "NetzkeGridPanelColumn",
        :ext_config        => {:title => false},
        # :conditions        => {:layout_id => config[:layout].id},
        :active            => true
      })
    end
    
    def actions
      super + [{
        :text => 'Restore defaults', :handler => 'loadDefaults'
      }]
    end
    
    def self.js_extend_properties
      super.merge({
        :load_defaults => <<-JS.l,
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
      NetzkeGridPanelColumn.create_layout_for_widget(parent.parent)
      {}
    end
    
  end
end