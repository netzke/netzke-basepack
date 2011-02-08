{
  initComponent: function() {
    Netzke.classes.Basepack.QueryBuilder.superclass.initComponent.call(this);
    this.add({title: "+", tooltip: "New OR tab"});

    this.on('beforetabchange', function(c, newTab, curentTab){
      if (newTab.title === '+') {
        this.addTab("OR");
        return false;
      } else {
        if (this.maxTabHeight) newTab.setHeight(this.maxTabHeight);
      }
    }, this);

  },

  addTab: function(title){
    var newTabConfig = Ext.apply({}, this.components.searchPanel);
    newTabConfig.id = newTabConfig.id + this.items.length;
    newTabConfig.title = title;
    newTabConfig.closable = true;
    var newTab = Ext.create(newTabConfig);

    this.insert(this.items.length - 1, newTab);

    this.suspendEvents();
    this.activate(newTab);
    this.resumeEvents();
  },

  getQuery: function() {
    var query = [];
    this.items.each(function(i) {
      if (i.title !== "+") {
        var q = i.getQuery();
        if (q.length > 0) query.push(i.getQuery());
      }
    });
    return query;
  }

}