{
  onSavePreset: function(){
    var searchName = this.presetsCombo.getRawValue();
    if (searchName !== "") {
      var presetsComboStore = this.presetsCombo.getStore();
      var existingPresetIndex = presetsComboStore.find('field2', searchName);
      if (existingPresetIndex !== -1) {
        Ext.Msg.confirm("Overwriting preset '" + searchName + "'", "Are you sure you want to overwrite this preset?", function(btn, text){
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
      Ext.Msg.confirm("Deleting preset '" + searchName + "'", "Are you sure you want to delete this preset?", function(btn, text){
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