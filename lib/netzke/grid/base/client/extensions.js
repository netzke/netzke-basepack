/**
 * Extended `Ext.data.reader.Array`, which can handle commands from the endpoint, and fires the 'endpointcommands' event
 * when commands are present in the endpoint response
 * @class Netzke.Grid.ArrayReader
 */
Ext.define('Netzke.Grid.ArrayReader', {
  extend: 'Ext.data.reader.Array',
  config: {
    rootProperty: 'data',
    successProperty: 'success',
    totalProperty: 'total',
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

/**
 * Data proxy that talks to Grid's endpoints
 * @class Netzke.Grid.Proxy
 */
Ext.define('Netzke.Grid.Proxy', {
  extend: 'Ext.data.proxy.Server',

  batch: function(options) {
    if (!options) return;
    for (operation in options.operations) {
      var op = new Ext.data.Operation({action: operation, records: options.operations[operation]});
      this[op.action](op, Ext.emptyFn, this);
    }
  },

  // NOTE: not used, as delete is being called directly from the grid
  destroy: function(op, callback, scope) {
    var data = Ext.Array.map(op.getRecords(), function(r) { return r.getData().id; });
    var store = this.grid.getStore();
    this.grid.server.destroy(data, function(res){
      var errors = [];
      for (var id in res) {
        var error;
        if (error = res[id].error) {
          errors.push(error);
          store.getRemovedRecords().forEach(function(record, i){
            if (record.getId() == id) {
              store.insert(record.index, record);
            }
          });
        }
      }

      // clear store state
      store.commitChanges();

      if (errors.length > 0) {
        this.grid.netzkeFeedback([errors]);
      }

      this.grid.getStore().load();

    }, this);
  },

  create: function(op, callback, scope) {
    var records = op.getRecords(),
        data = Ext.Array.map(records, function(r) { return Ext.apply(r.getData(), {internal_id: r.internalId}); });

    this.grid.server.create(data, function(res) {
      var errors = [];
      Ext.each(records, function(r) {
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

    this.grid.server.update(data, function(res) {
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
    this.grid.server.read(this.paramsFromOperation(operation), function(res) {
      this.processResponse(true, operation, {}, res, callback, scope);
    }, this);
    return {};
  },

  // Build consistent request params
  paramsFromOperation: function(operation) {
    var params = Ext.apply({}, this.getParams(operation));

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
