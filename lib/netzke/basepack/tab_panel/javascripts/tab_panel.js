{
  initComponent: function(params){
    this.callParent();
    this.on('tabchange', function(self, tab){
      if (tab && tab.wrappedComponent && !tab.items.first() && !tab.beingLoaded) {
        tab.beingLoaded = true; // prevent more than one request per tab in case of fast clicking
        this.netzkeLoadComponent({name: tab.wrappedComponent, container: tab.id}, function(){tab.beingLoaded = false});
      }
    }, this);
  }
}
