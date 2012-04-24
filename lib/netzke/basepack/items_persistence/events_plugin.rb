module Netzke
  module Basepack
    module ItemsPersistence
      class EventsPlugin < Netzke::Plugin
        js_method :init, <<-JS
          function(){
            this.callParent(arguments);

            this.cmp.on('afterlayout', function(){

              this.items.each(function(item, index, length){
                if (!item.oldSize) item.oldSize = item.getSize(); // remember initial size

                item.on('resize', function(panel, w, h){
                  var params = {item: panel.itemId};

                  if (panel.oldSize.width != w) {
                    params.width = w;
                  } else {
                    params.height = h;
                  }

                  panel.oldSize = panel.getSize();
                  this.regionResized(params);
                }, this);

                item.on('collapse', function(panel){
                  this.regionCollapsed({item: panel.itemId});
                }, this);

                item.on('expand', function(panel){
                  this.regionExpanded({item: panel.itemId});
                }, this);

              }, this);

            }, this.cmp, {single: true});
          }
        JS
      end
    end
  end
end
