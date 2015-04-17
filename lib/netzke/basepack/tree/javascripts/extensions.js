Ext.define('Netzke.classes.Basepack.Tree.Proxy', {
  extend: 'Ext.data.proxy.Server',

  batch: function(options) {
    if (!options) return;
    for (operation in options.operations) {
      var op = new Ext.data.Operation({action: operation, records: options.operations[operation]});
      this[op.action](op, Ext.emptyFn, this);
    }
  },

  read: function(operation, callback, scope) {
    this.grid.serverRead(this.paramsFromOperation(operation), function(res) {
      this.processResponse(true, operation, {}, res, callback, scope);
    }, this);
    return {};
  },

  // Build consistent request params
  paramsFromOperation: function(operation) {
    var params = Ext.apply({id: operation.getId()}, this.getParams(operation));

    if (params.filter) {
      params.filters = Ext.decode(params.filter);
      delete params.filter;
    }

    if (params.sort) {
      params.sorters = Ext.decode(params.sort);
      delete params.sort;
    }

    Ext.apply(params, this.extraParams);

    return params;
  }
});

/**
 * A fix for CheckColumn
 */
Ext.override(Ext.ux.CheckColumn, {
  processEvent: function(type) {
    // by returning true, we'll allow event propagation, so it reacts similarly to other columns
    if (this.readOnly && type == 'mousedown') return true;
    else return this.callOverridden(arguments);
  }
});
