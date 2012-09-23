module Netzke
  module Basepack
    # = AccordionPanel
    #
    # A panel with the 'accordion' layout. By default, lazily loads its nested components. For example:
    #
    #   class MyAccordion < Netzke::Basepack::AccordionPanel
    #     def items
    #       [{
    #         # just an Ext panel
    #         :html => "I'm a simple Ext.Panel",
    #         :title => "Panel One"
    #       },{
    #         # a Netzke component
    #         :klass => SimplePanel,
    #         :update_text => "Update for Panel Two",
    #         :title => "Panel Two"
    #       }]
    #     end
    #   end
    class AccordionPanel < Netzke::Base

      include WrapLazyLoaded

      js_configure do |c|
        c.layout = :accordion
        # c.component_load_mask = {:msg => "null".l} # due to a probable bug in Ext's Accordion Layout (mask message is mis-layed-out), disabling mask message

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
