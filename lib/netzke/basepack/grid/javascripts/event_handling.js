{
  // Handler for the 'add' button
  onAddInline: function(){
    if (this.enableEditInForm && !this.enableEditInline) {
      this.onAddInForm();
    } else {
      // Note: default values are taken from the model's field's defaultValue property
      var r = Ext.ModelManager.create({}, this.id);

      r.isNew = true; // to distinguish new records

      this.getStore().add(r);

      this.netzkeTryStartEditing(r);
    }
  },

  onDel: function() {
    Ext.Msg.confirm(this.i18n.confirmation, this.i18n.areYouSure, function(btn){
      if (btn == 'yes') {
        var ids = [], records = [];
        this.getSelectionModel().selected.each(function(r){
          if (r.isNew) {
            // this record is not know to server - simply remove from store
            this.store.remove(r);
          } else {
            ids.push(r.getId());
            records.push(r);
          }
        }, this);

        if (ids.length > 0){
          this.serverDelete(ids);
          this.getStore().reload();
        }
      }
    }, this);
  },

  onApply: function(){
    this.getStore().sync();
  },

  // Handlers for tools
  //

  onRefresh: function() {
    if (this.fireEvent('refresh', this) !== false) {
      this.store.load();
    }
  },

  // Event handlers
  //

  onItemContextMenu: function(grid, record, item, rowIndex, e){
    e.stopEvent();
    var coords = e.getXY();

    this.getSelectionModel().select(record, true);

    var menu = new Ext.menu.Menu({
      items: this.contextMenu
    });

    menu.showAt(coords);
  },

  onAfterRowMove: function(dt, oldIndex, newIndex, records){
    var ids = [];
    // collect records ids
    Ext.each(records, function(r){ids.push(r.id)});
    // call Grid's API
    this.moveRows({ids: Ext.encode(ids), new_index: newIndex});
  },

  /* Exception handler. TODO: will responses with status 200 land here? */
  loadExceptionHandler: function(proxy, response, operation){
    Netzke.warning('Server exception occured. Override loadExceptionHandler, or catch globally by listenning to serverexception event of Netzke.directProvider');
  },

  // Inline editing of 1 row
  onEdit: function(){
    var row = this.getSelectionModel().selected.first();
    if (row){
      this.netzkeTryStartEditing(row);
    }
  },

  // Not a very clean approach to clean-up. The problem is that this way the advanced search functionality stops being really pluggable. With Ext JS 4 find the way to make it truely so.
  onDestroy: function(){
    this.callParent();

    // Destroy the search window (here's the problem: we are not supposed to know it exists)
    if (this.searchWindow) {
      this.searchWindow.destroy();
    }
  }
}
