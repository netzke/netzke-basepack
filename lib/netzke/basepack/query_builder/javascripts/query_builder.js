{
  initComponent: function() {
    Netzke.classes.Basepack.QueryBuilder.superclass.initComponent.call(this);
    this.add({title: "+"});

    this.on('beforetabchange', function(c, newTab, curentTab){
      if (newTab.title === '+') {
        this.addTab(true);
        return false;
      } else {
        if (this.maxTabHeight) newTab.setHeight(this.maxTabHeight);
      }
    }, this);

    this.addEvents('conditionsupdate');

  },

  buildFormFromQuery: function(query) {
    this.onClearAll();

    if (query.length !== 0) {
      Ext.each(query, function(f, i){
        if (this.items.getCount() < i + 2) { this.addTab(); }
        this.items.get(i).buildFormFromQuery(query[i]);
      }, this);
    }

    this.doLayout();
  },

  addTab: function(activate){
    var newTabConfig = Ext.apply({}, this.components.searchPanel);
    newTabConfig.id = Ext.id(); // We need a unique ID every time
    newTabConfig.title = "OR";
    newTabConfig.closable = true;
    var newTab = Ext.create(newTabConfig);

    this.insert(this.items.getCount() - 1, newTab);

    if (activate) {
      this.suspendEvents();
      this.activate(newTab);
      this.resumeEvents();
    }
  },

  getQuery: function(all) {
    var query = [];
    this.eachTab(function(i) {
      var q = i.getQuery();
      if (q.length > 0) query.push(i.getQuery(all));
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
    this.items.each(function(f, i) {
      if (this.items.last() !== f) {
        fn.call(scope || f, f);
      }
    }, this);
  },

  onClearAll: function() {
    this.removeAllTabs(true);
    this.items.first().onClearAll();
  },

  onReset: function() {
    this.eachTab(function(t) { t.onReset(); });
  },

  removeAllTabs: function(exceptLast) {
    this.eachTab(function(t) { if (this.items.getCount() > (exceptLast ? 2 : 1)) {this.remove(t);} }, this);
  },

  onSavePreset: function(){
    var searchName = this.presetsCombo.getRawValue();

    if (searchName !== "") {
      var presetsComboStore = this.presetsCombo.getStore();
      var existingPresetIndex = presetsComboStore.find('field2', searchName);
      if (existingPresetIndex !== -1) {
        // overwriting
        Ext.Msg.confirm(this.i18n.overwriteConfirmTitle, String.format(this.i18n.overwriteConfirm, searchName), function(btn, text){
          if (btn == 'yes') {
            var r = presetsComboStore.getAt(existingPresetIndex);
            r.set('field1', this.getQuery(true));
            r.commit();
            this.doSavePreset(searchName);
          }
        }, this);
      } else {
        this.doSavePreset(searchName);
        var r = new presetsComboStore.recordType({field1: this.getQuery(true), field2: searchName});
        presetsComboStore.add(r);
      }
    }
  },

  doSavePreset: function(name){
    this.savePreset({
      name: name,
      query: Ext.encode(this.getQuery(true))
    });
  },

  onDeletePreset: function(){
    var searchName = this.presetsCombo.getRawValue();
    if (searchName !== "") {
      Ext.Msg.confirm(this.i18n.deleteConfirmTitle, String.format(this.i18n.overwriteConfirm, searchName), function(btn, text){
        if (btn == 'yes') {
          this.removePresetFromList(searchName);
          this.deletePreset({
            name: searchName
          });
        }
      }, this);
    }
  },

  onApply: function() {
    this.fireEvent('conditionsupdate', this.getQuery());
  },

  removePresetFromList: function(name){
    var presetsComboStore = this.presetsCombo.getStore();
    presetsComboStore.removeAt(presetsComboStore.find('field2', name));
    this.presetsCombo.reset();
  },

  i18n: {
    overwriteConfirm: "Are you sure you want to overwrite preset '{0}'?",
    overwriteConfirmTitle: "Overwriting preset",
    deleteConfirm: "Are you sure you want to delete preset '{0}'?",
    deleteConfirmTitle: "Deleting preset",
  }
}
