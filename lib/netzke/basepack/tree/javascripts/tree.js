{
  multiSelect: true,

  initComponent: function(){
    this.netzkeProcessColumns();
    this.netzkeBuildModel('Ext.data.TreeModel');
    this.netzkeBuildStore();

    delete this.root;

    this.plugins = [];
    this.plugins.push(Ext.create('Ext.grid.plugin.CellEditing', {pluginId: 'celleditor'}));

    this.callParent();

    this.setDynamicActionProperties(); // enable/disable actions (buttons) depending on selection
  },

  // Process selectionchange event to enable/disable actions
  setDynamicActionProperties: function() {
    this.getSelectionModel().on('selectionchange', function(selModel){
      // if (this.actions.add) this.actions.add.setDisabled(selModel.getCount() != 1);
      if (this.actions.edit) this.actions.edit.setDisabled(selModel.getCount() != 1);
    }, this);
  },

  netzkeBuildStore: function() {
    var store = Ext.create('Ext.data.TreeStore', Ext.apply({
      proxy: this.netzkeBuildProxy(),
      pruneModifiedRecords: true,
      remoteSort: true,
      remoteFilter: true,
      pageSize: this.rowsPerPage,
      root: this.root
    }, this.dataStore));

    delete this.dataStore;

    store.getProxy().getReader().on('endpointcommands', function(commands) {
      this.netzkeBulkExecute(commands);
    }, this);

    this.store = store;
    return store; // for backward compatibility
  },

  netzkeBuildProxy: function() {
    return Ext.create('Netzke.classes.Basepack.Tree.Proxy', {
      reader: this.netzkeBuildReader(),
      grid: this
    });
  },

  netzkeBuildReader: function() {
    var modelName = Netzke.modelName(this.id);
    return Ext.create('Ext.data.reader.Json', {
      model: modelName,
      rootProperty: 'data'
    });
  },

  // overriding
  onAddRecord: function(){
    var selected = this.getSelection()[0]

    this.netzkeLoadComponent("add_window", {
      callback: function(w){
        w.show();
        var form = w.items.first();
        form.on('apply', function(){
          if (!form.baseParams) form.baseParams = {};
          form.baseParams.parent_id = (selected || {}).id;
        }, this);

        w.on('close', function(){
          if (w.closeRes === "ok") {
            if (selected) {
              if (selected.isExpanded()) {
                this.store.load({node: selected});
              } else {
                selected.expand();
              }
            } else {
              this.store.load()
            }
          }
        }, this);
      }, scope: this
    });
  },

  // overriding
  onApply: function(){
    var topModified = this.store.getModifiedRecords()[0]; // the most top-level modified record
    this.store.sync();
    this.store.load({node: topModified.parentNode});
  },

  // overriding
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
  }

}
