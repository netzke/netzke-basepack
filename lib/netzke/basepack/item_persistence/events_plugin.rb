module Netzke
  module Basepack
    module ItemPersistence
      class EventsPlugin < Netzke::Plugin
        client_class do |c|
          c.init = l(<<-JS)
            function(cmp){
              cmp.on('afterlayout', function(){

                // scope of the parent panel
                this.items.each(function(item, index, length){
                  if (!item.oldSize) item.oldSize = item.getSize(); // remember initial size

                  item.on('resize', function(panel, w, h){
                    var params = {item: panel.itemId};

                    if ((panel.region == 'west' || panel.region == 'east') && panel.oldSize.width != w) {
                      params.width = w;
                      this.server.regionResized(params);
                    } else if (panel.region == 'north' || panel.region == 'south' && panel.oldSize.height != h){
                      params.height = h;
                      this.server.regionResized(params);
                    }

                    panel.oldSize = panel.getSize();
                  }, this);

                  item.on('collapse', function(panel){
                    this.server.regionCollapsed({item: panel.itemId});
                  }, this);

                  item.on('expand', function(panel){
                    this.server.regionExpanded({item: panel.itemId});
                  }, this);

                }, this);

              }, cmp, {single: true});
            }
          JS
        end
      end
    end
  end
end
