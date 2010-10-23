module Netzke
  module Basepack
    # A Panel with the 'accordion' layout. Can lazily load its nested components. For example:
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
      js_property :layout, 'accordion'
    
      def items
        orig = super.dup
        orig.each do |item|
          wrapped_component = components[item[:component]]
          # When a nested component with lazy loading is detected, it gets replaced with a 'fit' panel,
          # into which later the component itself is dynamically loaded on request.
          if wrapped_component && wrapped_component[:lazy_loading]
            item.replace({
              :layout => 'fit',
              :wrapped_component => wrapped_component[:name],
              :title => wrapped_component[:title] || wrapped_component[:name]
            })
          end
        end
        orig
      end
  
      js_method :init_component, <<-JS
        function(params){
          #{js_full_class_name}.superclass.initComponent.call(this);
          this.items.each(function(item){
            item.on('expand', function(i){
              if (i.wrappedComponent && !i.items.first()) {
                this.loadComponent({name: item.wrappedComponent, container: i.id});
              }
            }, this);
          }, this);
        }
      JS
    end
  end
end