Ext.define("Netzke.mixins.Basepack.GridEventHandlers", {
  // Handler for the 'add' button
  onAddRecord: function(){
    if (!this.editInline) {
      this.onAddInForm();
    } else {
      // Note: default values are taken from the model's field's defaultValue property
      var r = Ext.create(this.store.getModel(), {});

      r.isNew = true; // to distinguish new records

      this.getStore().add(r);

      this.nzTryStartEditing(r);
    }
  },

  onDel: function() {
    Ext.Msg.confirm(this.i18n.confirmation, this.i18n.areYouSure, function(btn){
      if (btn == 'yes') {
        var toDelete = this.getSelectionModel().getSelection();
        this.server.destroy(toDelete.map(function(r) { return r.id; }), function(res){
          var errors = [];
          for (var id in res) {
            var error;
            if (error = res[id].error) {
              errors.push(error);
            }
          }

          if (errors.length > 0) {
            this.nzFeedback([errors]);
          }
        });
        this.nzReloadStore();
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
      this.nzReloadStore();
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
    this.server.moveRows({ids: Ext.encode(ids), new_index: newIndex});
  },

  /* Exception handler. TODO: will responses with status 200 land here? */
  loadExceptionHandler: function(proxy, response, operation){
    Netzke.warning('Server exception occured. Override loadExceptionHandler, or catch globally by listenning to exception event of Netzke.directProvider');
  },

  onEdit: function(){
    var selection = this.getSelectionModel().getSelection();
    if (selection.length == 1) {
      this.doEdit(selection[0]);
    } else {
      this.doMultiEdit(selection);
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

  onAddInForm: function(){
    this.nzLoadComponent("add_window", {
      callback: function(w) {
        w.show();
        w.on('close', function(){
          if (w.closeRes === "ok") {
            this.nzReloadStore();
          }
        }, this);
      }
    });
  },

  // Edit single record
  doEdit: function(record){
    if (this.editInline) {
      this.doEditInline(record);
    } else {
      this.doEditInForm(record);
    }
  },

  // Edit multiple records via form
  doMultiEdit: function(records){
    this.nzLoadComponent("multi_edit_window", {
      callback: function(w){
        var form = w.items.first();
        // +apply+ is called by wrapping window on OK click
        form.on('apply', function(){
          var ids = [];
          Ext.each(records, function(r){
            ids.push(r.getId());
          });
          if (!form.baseParams) form.baseParams = {};
          form.baseParams.ids = Ext.encode(ids);
        }, this);

        w.on('close', function(){
          if (w.closeRes === "ok") {
            this.nzReloadStore();
          }
        }, this);
      }
    });
  },

  // Edit record inline
  doEditInline: function(record){
    this.nzTryStartEditing(record);
  },

  // Single record editing
  doEditInForm: function(record){
    this.nzLoadComponent("edit_window", {
      serverConfig: {record_id: record.id},
      callback: function(w){
        w.show();
        w.on('close', function(){
          if (w.closeRes === "ok") {
            this.nzReloadStore();
          }
        }, this);
      }});
  },

  nzReloadStore: function(){
    var store = this.getStore();

    // HACK to work around buffered store's buggy reload()
    if (!store.lastRequestStart) {
      store.load();
    } else store.reload();
  }
});
