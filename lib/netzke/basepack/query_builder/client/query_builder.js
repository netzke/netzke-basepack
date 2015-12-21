{
  initComponent: function() {
    this.callParent();

    this.presetsCombo = this.down("combo[itemId='presets-combo']");

    this.add({title: "+"});

    this.on('beforetabchange', function(c, newTab, curentTab){
      if (newTab.title === '+') {
        this.addTab(true, true);
        return false;
      } else {
        if (this.maxTabHeight) newTab.setHeight(this.maxTabHeight);
      }
    }, this);

    this.addTab(true, false);

  },

  buildFormFromQuery: function(query) {
    this.handleClearAll();

    if (query.length !== 0) {
      Ext.each(query, function(f, i){
        var closable = i === 0 ? false : true;
        if (this.items.getCount() < i + 2) { this.addTab(false, closable); }
          this.items.get(i).items.first().buildFormFromQuery(query[i]);
      }, this);
    }

    this.doLayout();
  },

  addTab: function(activate, closable){
    var newTabConfig = Ext.apply({}, this.netzkeComponents.searchPanel);
    newTabConfig.id = Ext.id(); // We need a unique ID every time
    newTabConfig.header = false;
    newTabConfig.border = false;

    var newTab = this.insert(
      this.items.getCount() - 1,
      {
        title: "OR",
        closable: closable,
        items: [
          Ext.createByAlias(newTabConfig.alias, newTabConfig)
        ]
      }
    );

    if (activate) {
      this.suspendEvents();
      this.setActiveTab(newTab);
      this.resumeEvents();
    }
  },

  getQuery: function(all) {
    var query = [];
    this.eachTab(function(i) {
      var q = i.items.first().getQuery();
      if (q.length > 0) query.push(i.items.first().getQuery(all));
    });
    return query;
  },

  getTabs: function() {
    var res = [];
    this.items.each(function(i) {
      if (i.title !== "+") { res.push(i); }
    });
    return res;
  },

  eachTab: function(fn, scope) {
    this.items.each(function(f) {
      if (f.title !== "+") {
        fn.call(scope || f, f);
      }
    }, this);
  },

  handleClearAll: function() {
    this.removeAllTabs(true);
    this.getActiveTab().items.first().handleClearAll();
  },

  handleReset: function() {
    this.eachTab(function(t) {
      t.items.first().onReset();
    });
  },

  removeAllTabs: function(exceptLast) {
    this.eachTab(function(t) { if (this.items.getCount() > (exceptLast ? 2 : 1)) {this.remove(t);} }, this);
  },

  handleSavePreset: function(){
    var searchName = this.presetsCombo.getRawValue();

    if (searchName !== "") {
      var presetsComboStore = this.presetsCombo.getStore();
      var existingPresetIndex = presetsComboStore.find('text', searchName);
      if (existingPresetIndex !== -1) {
        // overwriting
        Ext.Msg.confirm(this.i18n.overwriteConfirmTitle, Ext.String.format(this.i18n.overwriteConfirm, searchName), function(btn, text){
          if (btn == 'yes') {
            var r = presetsComboStore.getAt(existingPresetIndex);
            r.set('value', this.getQuery(true));
            r.commit();
            this.doSavePreset(searchName);
          }
        }, this);
      } else {
        this.doSavePreset(searchName);
        presetsComboStore.add({value: this.getQuery(true), text: searchName});
      }
    }
  },

  doSavePreset: function(name){
    this.server.savePreset({
      name: name,
      query: Ext.encode(this.getQuery(true))
    });
  },

  handleDeletePreset: function(){
    var searchName = this.presetsCombo.getRawValue();
    if (searchName !== "") {
      Ext.Msg.confirm(this.i18n.deleteConfirmTitle, Ext.String.format(this.i18n.deleteConfirm, searchName), function(btn, text){
        if (btn == 'yes') {
          this.removePresetFromList(searchName);
          this.server.deletePreset({
            name: searchName
          });
        }
      }, this);
    }
  },

  handleApply: function() {
    this.fireEvent('conditionsupdate', this.getQuery());
  },

  removePresetFromList: function(name){
    var presetsComboStore = this.presetsCombo.getStore();
    presetsComboStore.removeAt(presetsComboStore.find('text', name));
    this.presetsCombo.reset();
  },

  presetSelectorConfig: function(config) {
    return {
      itemId: 'presets-combo',
      xtype: "combo",
      triggerAction: "all",
      store: config.presetStore,
      listeners: {
        beforeselect: function(self, record) {
          this.netzkeParent.buildFormFromQuery(record.get('field1'));
        }
      },
    }
  }
}
