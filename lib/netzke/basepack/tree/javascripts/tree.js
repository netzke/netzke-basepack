{
  multiSelect: true,

  initComponent: function(){
    this.netzkeProcessColumns();
    this.netzkeBuildModel('Ext.data.TreeModel');
    this.netzkeBuildStore();

    delete this.root;

    this.callParent();
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
  }
}
