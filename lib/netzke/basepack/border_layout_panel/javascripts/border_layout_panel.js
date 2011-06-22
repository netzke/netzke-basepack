{
  layout: 'border',

  initComponent: function(){
    this.callParent();

    // First time on "afterlayout", set resize events
    if (this.persistence) {this.on('afterlayout', this.setRegionEvents, this, {single: true});}
  },

  setRegionEvents: function(){
    this.items.each(function(item, index, length){
      if (!item.oldSize) item.oldSize = item.getSize(); // remember initial size

      item.on('resize', function(panel, w, h){
        if (panel.region !== 'center' && w && h) {
          var params = {region:panel.region};

          if (panel.oldSize.width != w) {
            params.width = w;
          } else {
            params.height = h;
          }

          panel.oldSize = panel.getSize();
          this.regionResized(params);
        }
      }, this);

      item.on('collapse', function(panel){
        this.regionCollapsed({region: panel.region});
      }, this);

      item.on('expand', function(panel){
        this.regionExpanded({region: panel.region});
      }, this);

    }, this);
  }
}
