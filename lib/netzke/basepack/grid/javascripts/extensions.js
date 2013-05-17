/**
 * Extended Ext.data.reader.Array, which can handle commands from the endpoint, and fires the 'endpointcommands' event
 * when commands are present in the endpoint response
 */
Ext.define('Netzke.classes.Basepack.Grid.ArrayReader', {
  extend: 'Ext.data.reader.Array',
  root: 'data',
  successProperty: 'success',
  totalProperty: 'total',
  constructor: function() {
    this.callParent(arguments);
    this.addEvents('endpointcommands');
  },
  read: function(response) {
    var data = {data: response.data, total: response.total, success: response.success};
    delete(response.data);
    delete(response.total);
    delete(response.success);
    this.fireEvent('endpointcommands', response);
    return this.callParent([data]);
  }
});

Ext.define('Netzke.classes.Basepack.Grid.Proxy', {
  extend: 'Ext.data.proxy.Server',

  batch: function(options) {
    if (!options) return;
    for (operation in options.operations) {
      var op = new Ext.data.Operation({action: operation, records: options.operations[operation]});
      this[op.action](op, Ext.emptyFn, this);
    }
  },

  create: function(op, callback, scope) {
    var data = Ext.Array.map(op.getRecords(), function(r) { return Ext.apply(r.getData(), {internal_id: r.internalId}); });

    this.grid.serverCreate(data, function(res) {
      var errors = [];
      Ext.each(op.records, function(r) {
        var rid = r.internalId,
            recordData = res[rid].record,
            error = res[rid].error;
        if (recordData) {
          serverRecord = this.getReader().read({data: [res[rid].record]}).records[0];
          r.copyFrom(serverRecord);
          r.commit();
        }
        if (error) { errors.push(error); }
      }, this);

      if (errors.length == 0) {
        this.grid.getStore().load();
      } else {
        this.grid.netzkeFeedback(errors);
      }

    }, this);
  },

  update: function(op, callback, scope) {
    var data = Ext.Array.map(op.getRecords(), function(r) { return r.getData(); });

    this.grid.serverUpdate(data, function(res) {
      var errors = [];
      Ext.each(op.records, function(r) {
        var rid = r.getId(),
            recordData = res[rid].record,
            error = res[rid].error;
        if (recordData) {
          serverRecord = this.getReader().read({data: [res[rid].record]}).records[0];
          r.copyFrom(serverRecord);
          r.commit();
        }
        if (error) { errors.push(error); }
      }, this);

      if (errors.length == 0) {
        this.grid.getStore().load();
      } else {
        this.grid.netzkeFeedback(errors);
      }
    }, this);
  },

  read: function(operation, callback, scope) {
    this.grid.serverRead(this.paramsFromOperation(operation), function(res) {
      this.processResponse(true, operation, {}, res, callback, scope);
    }, this);
    return {};
  },

  // Build consistent request params
  paramsFromOperation: function(operation) {
    var params = Ext.copyTo({}, operation, 'limit,start,sorters,filters');
    if (operation.params && operation.params.filter) params.filters = Ext.decode(operation.params.filter);
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
