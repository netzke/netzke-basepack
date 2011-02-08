{
  initComponent: function(params){
    Netzke.classes.Basepack.TabPanel.superclass.initComponent.call(this);
    this.on('tabchange', function(self, i){
      if (i && i.wrappedComponent && !i.items.first() && !i.beingLoaded) {
        i.beingLoaded = true; // prevent more than one request per tab in case of fast clicking
        this.loadComponent({name: i.wrappedComponent, container: i.id}, function(){i.beingLoaded = false});
      }
    }, this);
  }
}
