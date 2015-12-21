{
  multiSelect: true,

  initComponent: function(){
    this.netzkeProcessColumns();
    this.netzkeBuildStore();

    delete this.root;

    if (this.config.dragDrop) {
      this.netzkeSetDragDrop();
    }

    this.plugins = this.plugins || [];
    this.plugins.push(Ext.create('Ext.grid.plugin.CellEditing', {pluginId: 'celleditor'}));

    this.callParent();

    this.netzkeSetActionEvents();

    this.getView().on('afteritemcollapse', this.handleNodeStateChange, this);
    this.getView().on('afteritemexpand', this.handleNodeStateChange, this);

    this.store.on('load', function(){
      var root = this.getRootNode();
      root.collapse();
      root.expand(false);
    }, this);

    if (!this.editInline) {
      this.on('itemdblclick', function(view, record) {
        this.doEditInForm(record);
      }, this);
    }
  },

  handleNodeStateChange: function(node){
    this.server.updateNodeState({id: node.get('id'), expanded: node.isExpanded()});
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
    return Ext.create('Netzke.Basepack.Tree.Proxy', {
      reader: 'json',
      grid: this
    });
  },

  netzkeSetDragDrop: function() {
    this.nezkeInitViewConfig();

    this.viewConfig.plugins.push(
      Ext.create('Ext.tree.plugin.TreeViewDragDrop', {
          enableDrag: true
        })
    );

    this.viewConfig.listeners['drop'] = function( node, data, overModel, dropPosition, eOpts ) {
      var parentId = (dropPosition == 'append') ? overModel.id : overModel.data.parentId;
      var dataRecords = data.records;
      var records = dataRecords.map(function(element){ return { id: element.id, parentId: parentId } });
      this.panel.server.updateParentId(records, function(response){
        dataRecords.forEach(function(record){
          if (record.modified !== undefined &&
            Object.keys(record.modified).length == 1
            && record.modified["parentId"] !== undefined){
              record.dirty = false;
              delete record.modified["parentId"];
          }
        });
      });
    }
  },

  nezkeInitViewConfig: function() {
    this.viewConfig = this.viewConfig || {};
    this.viewConfig.plugins = this.viewConfig.plugins || [];
    this.viewConfig.listeners = this.viewConfig.listeners || {};
  },

  // overriding
  handleAdd: function(){
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
  handleApply: function(){
    var topModified = this.store.getModifiedRecords()[0]; // the most top-level modified record
    this.store.sync();
    this.store.load({node: topModified.parentNode});
  },

  // overriding
  handleDel: function() {
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

}
