module Netzke
  #
  # Ext.grid.PropertyGrid
  #
  class PropertyGrid < Base
    interface :load_source, :submit_source
    
    def initialize(*args)
      super
      @config = {:ext_config => {}}.merge(@config)
    end

    def self.js_base_class
      "Ext.grid.PropertyGrid"
    end

    def actions
      [{
        :text => 'Apply', :handler => 'submit'
      }]
    end

    def self.js_default_config
      super.merge({
        :bbar => "config.actions".l
      })
    end
    
    def self.js_extend_properties
      {
        :submit => <<-JS.l,
        function() {
          Ext.Ajax.request({
            url:this.initialConfig.interface.submitSource,
            params:{data:Ext.encode(this.getSource())},
            scope:this
          })
        }
        JS
        :on_widget_load => <<-JS.l,
        function(){
          this.loadSource()
        }
        JS
        :load_source => <<-JS.l,
          function(){Ext.Ajax.request({
            url:this.initialConfig.interface.loadSource,
            success:function(r){
              var m = Ext.decode(r.responseText);
              this.setSource(m.source);
              // this.feedback(m.flash);
            },
            scope:this
          })}
        JS
      }
    end
    
  end
end