{
  tabCounter: 0,

  nzTabComponentDelivered: function(c, config) {
    var tab,
        i,
        activeTab = this.getActiveTab(),
        cmp = Ext.create(Ext.apply(c, {closable: true}));

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

  nzLoadComponentByClass: function(klass, options) {
    this.nzLoadComponent('child', Ext.apply(options, {
      configOnly: true,
      itemId: "tab_" + this.tabCounter++,
      serverConfig: Ext.apply(options.serverConfig || {}, { class_name: klass }),
      callback: this.nzTabComponentDelivered
    }));
  }
}
