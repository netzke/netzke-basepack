/**
 * Event handlers for grid-like components, gets mixed into `Netzke.Grid.Base` and `Netzke.Tree.Base`
 * @class Netzke.Grid.EventHandlers
 */
Ext.define("Netzke.Grid.EventHandlers", {
  // Handler for the 'add' button
  netzkeOnAdd: function(){
    if (this.editing == 'in_form') {
      this.netzkeOnAddInForm();
    } else {
      // Note: default values are taken from the model's field's defaultValue property
      var r = Ext.create(this.store.getModel(), {});

      r.isNew = true; // to distinguish new records

      this.getStore().add(r);

      this.netzkeTryStartEditing(r);
    }
  },

  netzkeOnDelete: function() {
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
            this.netzkeNotify(errors);
          }
        });
        this.netzkeReloadStore();
      }
    }, this);
  },

  netzkeOnApply: function(){
    this.getStore().sync();
  },

  // Handlers for tools
  //

  netzkeOnRefreshTool: function() {
    if (this.fireEvent('netzkerefresh', this) !== false) {
      this.netzkeReloadStore();
    }
  },

  // Event handlers
  //

  netzkeOnItemContextMenu: function(grid, record, item, rowIndex, e){
    e.stopEvent();
    var coords = e.getXY();

    this.getSelectionModel().select(record, true);

    var menu = new Ext.menu.Menu({
      items: this.contextMenu
    });

    menu.showAt(coords);
  },

  netzkeOnAfterRowMove: function(dt, oldIndex, newIndex, records){
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

  netzkeOnEdit: function(){
    var selection = this.getSelectionModel().getSelection();
    if (selection.length == 1) {
      this.doEdit(selection[0]);
    } else {
      this.doMultiEdit(selection);
    }
  },

  netzkeOnEditInForm: function(){
    var selection = this.getSelectionModel().getSelection();
    if (selection.length == 1) {
      this.doEditInForm(selection[0]);
    } else {
      this.doMultiEdit(selection);
    }
  },

  netzkeOnAddInForm: function(){
    this.netzkeLoadComponent("add_window", {
      callback: function(w) {
        w.show();
        w.on('close', function(){
          if (w.closeRes === "ok") {
            this.netzkeReloadStore();
          }
        }, this);
      }
    });
  },

  // Edit single record using default mode
  doEdit: function(record){
    if (this.editsInline) {
      this.doEditInline(record);
    } else {
      this.doEditInForm(record);
    }
  },

  // Edit multiple records via form
  doMultiEdit: function(records){
    this.netzkeLoadComponent("multiedit_window", {
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
            this.netzkeReloadStore();
          }
        }, this);
      }
    });
  },

  // Edit record inline
  doEditInline: function(record){
    this.netzkeTryStartEditing(record);
  },

  // Single record editing
  doEditInForm: function(record){
    this.netzkeLoadComponent("edit_window", {
      serverConfig: {record_id: record.id},
      callback: function(w){
        w.show();
        w.on('close', function(){
          if (w.closeRes === "ok") {
            this.netzkeReloadStore();
          }
        }, this);
      }});
  },

  /**
   * Reloads store
   * @method netzkeReloadStore
   */
  netzkeReloadStore: function(){
    var store = this.getStore();

    // HACK to work around buffered store's buggy reload()
    if (!store.lastRequestStart) {
      store.load();
    } else store.reload();
  },

  /**
   * Processes selectionchange event to enable/disable actions.
   * @method netzkeSetActionEvents
   * @private
   */
  netzkeSetActionEvents: function(){
    this.getSelectionModel().on('selectionchange', function(selModel, selected){
      if (this.actions.delete) this.actions.delete.setDisabled(selected.length == 0);

      if (this.actions.edit) {
        var disabled = false;
        Ext.each(selected, function(r){
          if (r.isNew) { disabled = true; return false; }
        });
        this.actions.edit.setDisabled(selected.length == 0 || disabled);
      }

      if (this.actions.editInForm) {
        this.actions.editInForm.setDisabled(selected.length == 0);
      }
    }, this);
  },

  /**
   * Loads edit form if editing in form is possible.
   * @method netzkeHandleItemdblclick
   */
  netzkeHandleItemdblclick: function(view, record){
    if (this.editsInline) return; // inline editing is handled elsewhere

    if ((this.permissions || {}).update !== false) {
      this.doEditInForm(record);
    }
  },

  netzkeOnColumnAction: function(self, i, j, options){
    var handlerName = "netzkeOn" + options.passedHandler;
    var f = this[handlerName];
    if (Ext.isFunction(f)) {
      f.apply(this, arguments);
    } else {
      Netzke.warning("Undefined handler '"+handlerName+"'");
    }
  },

  netzkeHandleBeforeEdit: function(_, field){
    return this.netzkePermitInlineEdit(field.record);
  },

  /**
   * Whether given record can be edited
   * @method netzkePermitInlineEdit
   * @return {Boolean}
   */
  netzkePermitInlineEdit: function(record) {
    return this.editsInline && (this.netzkePermits('update') || !!record.isNew);
  }
});
