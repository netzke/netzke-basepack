{
  initComponent: function(params){
    Netzke.classes.Basepack.TabPanel.superclass.initComponent.call(this);
    this.on('tabchange', function(self, tab){
      if (tab && tab.wrappedComponent && !tab.items.first() && !tab.beingLoaded) {
        tab.beingLoaded = true; // prevent more than one request per tab in case of fast clicking
        this.loadNetzkeComponent({name: tab.wrappedComponent, container: tab.id}, function(){tab.beingLoaded = false});
      }
    }, this);
  }
}
