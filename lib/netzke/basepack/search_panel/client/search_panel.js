{
  initComponent: function() {
    this.callParent();
    this.buildFormFromQuery(this.presetQuery);

    this.handleAddCondition();

  },

  // Will probably need to be performance-optimized in the future, as recreating the fields is expensive
  buildFormFromQuery: function(query) {
    this.handleClearAll();
    Ext.each(query, function(f){
      f.ownerCt = this;
      this.insert(this.items.length - 1, Ext.createByAlias('widget.netzkebasepacksearchpanelconditionfield', f));
    }, this);
    this.doLayout();
  },

  handleAddCondition: function() {
    var condField = Ext.createByAlias('widget.netzkebasepacksearchpanelconditionfield', {ownerCt: this});
    condField.on('configured', function() {
      this.handleAddCondition();
    }, this, {single: true});
    this.add(condField);
    this.doLayout();
    this.fireEvent('fieldsnumberchange');
  },

  handleReset: function() {
    this.items.each(function(f){
      if (f.valueField) {f.clearValue();}
    });
  },

  handleClearAll: function() {
    this.eachConfiguredField(function(f) {
      this.remove(f);
    }, this);

    this.fireEvent('fieldsnumberchange');
  },

  // Returns each condition field which has attribute selected
  eachConfiguredField: function(fn, scope) {
    this.items.each(function(f, i) {
      if (this.items.last() !== f) {
        fn.call(scope || f, f);
      }
    }, this);
  },

  // When "all" is "true", also includes the fields with empty values
  getQuery: function(all) {
    var query = [];
    this.eachConfiguredField(function(f){
      if (f.valueIsSet() || all) {
        var cond = f.buildValue();
        if (all) {cond.type = f.type;}
        query.push(cond);
      }
    });
    return query;
  }
}
