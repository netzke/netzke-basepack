module Netzke
  module Basepack
    # = AccordionPanel
    # 
    # A panel with the 'accordion' layout. Can lazily load its nested components. For example:
    # 
    #     netzke :my_accordion, :items => [{
    #         :html => "I'm a simple Ext.Panel",
    #         :title => "Panel One"
    #       },{
    #         :class_name => "SimplePanel",
    #         :update_text => "Update for Panel Two",
    #         :title => "Panel Two",
    #         :lazy_loading => true
    #       }]
    class AccordionPanel < Netzke::Base
      
      include WrapLazyLoaded
      
      js_property :layout, 'accordion'
    
      js_method :init_component, <<-JS
        function(params){
          #{js_full_class_name}.superclass.initComponent.call(this);
          this.items.each(function(item){
            item.on('expand', function(i){
              if (i.wrappedComponent && !i.items.first()) {
                this.loadComponent({name: i.wrappedComponent, container: i.id});
              }
            }, this);
          }, this);
        }
      JS
      
    end
  end
end