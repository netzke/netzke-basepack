{
  netzkeTabComponentDelivered: function(c, config) {
    var tab,
        i,
        activeTab = this.getActiveTab(),
        cmp = Ext.ComponentManager.create(Ext.apply(c, {closable: true}));

    if (config.newTab || activeTab == null) {
      tab = this.add(cmp);
    } else {
      tab = this.getActiveTab();
      i = this.items.indexOf(tab);
      this.remove(tab);
      tab = this.insert(i, cmp);
    }

    this.setActiveTab(tab);
  },

  netzkeLoadComponentByClass: function(klass, options) {
    this.netzkeLoadComponent('child', Ext.apply(options, {
      configOnly: true,
      clone: true,
      clientConfig: Ext.apply(options.clientConfig || {}, {klass: klass}),
      callback: this.netzkeTabComponentDelivered,
      scope: this,
    }));
  }
}
