Ext.define("Netzke.mixins.Basepack.GridEventHandlers", {
  // Handler for the 'add' button
  onAddRecord: function(){
    if (this.enableEditInForm && !this.enableEditInline) {
      this.onAddInForm();
    } else {
      // Note: default values are taken from the model's field's defaultValue property
      var r = Ext.create(this.store.getModel(), {});

      r.isNew = true; // to distinguish new records

      this.getStore().add(r);

      this.netzkeTryStartEditing(r);
    }
  },

  onDel: function() {
    Ext.Msg.confirm(this.i18n.confirmation, this.i18n.areYouSure, function(btn){
      if (btn == 'yes') {
        var toDelete = this.getSelectionModel().getSelection();
        store = this.getStore();
        store.remove(toDelete);
        store.removedNodes = toDelete; // HACK
        store.sync();
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
      this.store.reload();
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
    Netzke.warning('Server exception occured. Override loadExceptionHandler, or catch globally by listenning to exception event of Netzke.directProvider');
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
  },

  onEditInForm: function(){
    var selModel = this.getSelectionModel();
    if (selModel.getCount() > 1) {
      var recordId = selModel.selected.first().getId();
      this.netzkeLoadComponent("multi_edit_window", {
        callback: function(w){
          var form = w.items.first();
          // +apply+ is called by wrapping window on OK click
          form.on('apply', function(){
            var ids = [];
            selModel.selected.each(function(r){
              ids.push(r.getId());
            });
            if (!form.baseParams) form.baseParams = {};
            form.baseParams.ids = Ext.encode(ids);
          }, this);

          w.on('close', function(){
            if (w.closeRes === "ok") {
              this.store.reload();
            }
          }, this);
        }});
    } else {
      var recordId = selModel.selected.first().getId();
      this.netzkeLoadComponent("edit_window", {
        serverConfig: {record_id: recordId},
        callback: function(w){
          w.show();
          w.on('close', function(){
            if (w.closeRes === "ok") {
              this.store.reload();
            }
          }, this);
        }});
    }
  },

  onAddInForm: function(){
    this.netzkeLoadComponent("add_window", {
      callback: function(w) {
        w.show();
        w.on('close', function(){
          if (w.closeRes === "ok") {
            this.store.reload();
          }
        }, this);
      }
    });
  }
});
