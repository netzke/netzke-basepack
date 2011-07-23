{
  // Handler for the 'add' button
  onAddInline: function(){
    // Note: default values are taken from the model's field's defaultValue property
    var r = Ext.ModelManager.create({}, this.id),
        editor = this.getPlugin('celleditor');

    r.isNew = true; // to distinguish new records

    this.getStore().add(r);

    this.tryStartEditing(r);
  },

  onDel: function() {
    Ext.Msg.confirm(this.i18n.confirmation, this.i18n.areYouSure, function(btn){
      if (btn == 'yes') {
        var records = [];
        var selection = this.getView().getSelectedNodes();
        this.getSelectionModel().selected.each(function(r){
          if (r.isNew) {
            // this record is not know to server - simply remove from store
            this.store.remove(r);
          } else {
            records.push(r.getId());
          }
        }, this);

        if (records.length > 0){
          if (!this.deleteMask) this.deleteMask = new Ext.LoadMask(this.getEl(), {msg: this.deleteMaskMsg});
          this.deleteMask.show();
          // call API
          this.deleteData({records: Ext.encode(records)}, function(){
            this.deleteMask.hide();
          }, this);
        }
      }
    }, this);
  },

  onApply: function(){
    var newRecords = [],
        updatedRecords = [],
        store = this.getStore();

    Ext.each(store.getUpdatedRecords().concat(store.getNewRecords()),
      function(r) {
        if (r.isNew) {
          newRecords.push(r.data); // HACK: r.data seems private
        } else {
          updatedRecords.push(Ext.apply(r.getChanges(), {id:r.getId()}));
        }
      },
    this);

    if (newRecords.length > 0 || updatedRecords.length > 0) {
      var params = {};

      if (newRecords.length > 0) {
        params.created_records = Ext.encode(newRecords);
      }

      if (updatedRecords.length > 0) {
        params.updated_records = Ext.encode(updatedRecords);
      }

      if (this.getStore().getProxy().extraParams !== {}) {
        params.base_params = Ext.encode(this.getStore().getProxy().extraParams);
      }

      this.postData(params);
    }

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

  onColumnResize: function(ct, cl, width){
    var index = ct.items.findIndex('id', cl.id);

    this.resizeColumn({
      index: index,
      size:  width
    });
  },

  onColumnHide: function(ct, cl){
    var index = ct.items.findIndex('id', cl.id);

    this.hideColumn({
      index:index,
      hidden:true
    });
  },

  onColumnShow: function(ct, cl){
    var index = ct.items.findIndex('id', cl.id);

    this.hideColumn({
      index:index,
      hidden:false
    });
  },

  onColumnMove: function(ct, cl, oldIndex, newIndex){
    this.moveColumn({
      old_index: oldIndex,
      new_index: newIndex
    });
  },

  onItemContextMenu: function(grid, record, item, rowIndex, e){
    e.stopEvent();
    var coords = e.getXY();

    if (!grid.getSelectionModel().isSelected(rowIndex)) {
      grid.getSelectionModel().selectRow(rowIndex);
    }

    var menu = new Ext.menu.Menu({
      items: this.contextMenu
    });

    menu.showAt(coords);
  },

  onAfterRowMove: function(dt, oldIndex, newIndex, records){
    var ids = [];
    // collect records ids
    Ext.each(records, function(r){ids.push(r.id)});
    // call GridPanel's API
    this.moveRows({ids: Ext.encode(ids), new_index: newIndex});
  },

  // Other methods. TODO: revise
  //

  /* Exception handler. TODO: will responses with status 200 land here? */
  loadExceptionHandler: function(proxy, response, operation){
    this.netzkeFeedback(response.message);
    // if (response.status == 200 && (responseObject = Ext.decode(response.responseText)) && responseObject.flash){
    //   this.feedback(responseObject.flash);
    // } else {
    //   if (error){
    //     this.feedback(error.message);
    //   } else {
    //     this.feedback(response.statusText);
    //   }
    // }
  },

  // Inline editing of 1 row
  onEdit: function(){
    var row = this.getSelectionModel().selected.first();
    if (row){
      this.tryStartEditing(row);
    }
  },

  // Not a very clean approach to clean-up. The problem is that this way the advanced search functionality stops being really pluggable. With Ext JS 4 find the way to make it truely so.
  onDestroy: function(){
    Netzke.classes.Basepack.GridPanel.superclass.onDestroy.call(this);

    // Destroy the search window (here's the problem: we are not supposed to know it exists)
    if (this.searchWindow) {
      this.searchWindow.destroy();
    }
  }
}