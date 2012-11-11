module Netzke
  module Basepack
    # A panel with the 'accordion' layout. By default, lazily loads its nested components. For example:
    #
    #   class MyAccordion < Netzke::Basepack::AccordionPanel
    #     def configure(c)
    #       super
    #       c.items = [{
    #         # just an Ext panel
    #         :html => "I'm a simple Ext.Panel",
    #         :title => "Panel One"
    #       },{
    #         # a Netzke component
    #         :component => :my_component,
    #         :title => "Panel Two"
    #       }]
    #     end
    #
    #     component :my_component
    #   end
    class AccordionPanel < Netzke::Base

      include WrapLazyLoaded

      js_configure do |c|
        c.layout = :accordion

        c.init_component = <<-JS
          function(params){
            this.callParent();
            this.items.each(function(item){
              item.on('expand', function(i){
                if (i && i.wrappedComponent && !i.items.first() && !i.beingLoaded) {
                  i.beingLoaded = true; // prevent more than one request per panel in case of fast clicking
                  this.loadNetzkeComponent({name: i.wrappedComponent, container: i.id}, function(){i.beingLoaded = false});
                }
              }, this);
            }, this);
          }
        JS
      end

    end
  end
end
