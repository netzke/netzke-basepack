{
  initComponent: function(params){
    this.superclass.initComponent.call(this);
    this.on('tabchange', function(self, i){
      if (i && i.wrappedComponent && !i.items.first()) {
        this.loadComponent({name: i.wrappedComponent, container: i.id});
      }
    }, this);
  }
}
