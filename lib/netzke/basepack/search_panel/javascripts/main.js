{
  i18n: {
    overwriteConfirm: "Are you sure you want to overwrite preset '{0}'?",
    overwriteConfirmTitle: "Overwriting preset",
    deleteConfirm: "Are you sure you want to delete preset '{0}'?",
    deleteConfirmTitle: "Deleting preset",
  },

  initComponent: function() {
    Netzke.classes.Basepack.SearchPanel.superclass.initComponent.call(this);
    this.buildFormFromQuery(this.query);

    this.addEvents('conditionsupdate', 'fieldsnumberchange');
  },

  onApply: function() {
    this.fireEvent('conditionsupdate', this.getQuery());
  },

  // Will probably need to be performance-optimized in the future, as recreating the fields is expensive
  buildFormFromQuery: function(query) {
    Ext.each(query, function(f){
      this.add(Ext.apply(f, {xtype: 'netzkebasepacknewsearchpanelconditionfield'}));
    }, this);
    this.doLayout();
  },

  onAddCondition: function() {
    this.add({xtype: 'netzkebasepacknewsearchpanelconditionfield'});
    this.doLayout();
    this.fireEvent('fieldsnumberchange');
  },

  onReset: function() {
    this.items.each(function(f){
      f.clearValue();
    });
  },

  onRemoveAll: function() {
    this.removeAll();
    this.fireEvent('fieldsnumberchange');
  },

  // When "all" is "true", also includes the fields with empty values
  getQuery: function(all) {
    var query = [];
    this.items.each(function(f){
      if (f.valueIsSet() || all) {
        var cond = f.buildValue();
        if (all) {cond.attrType = f.attrType;}
        query.push(cond);
      }
    });
    return query;
  },

  onSavePreset: function(){
    var searchName = this.presetsCombo.getRawValue();
    if (searchName !== "") {
      var presetsComboStore = this.presetsCombo.getStore();
      var existingPresetIndex = presetsComboStore.find('field2', searchName);
      if (existingPresetIndex !== -1) {
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

  removePresetFromList: function(name){
    var presetsComboStore = this.presetsCombo.getStore();
    presetsComboStore.removeAt(presetsComboStore.find('field2', name));
    this.presetsCombo.reset();
  }
}
