Ext.define('Netzke.Tree.Proxy', {
  extend: 'Ext.data.proxy.Server',

  batch: function(options) {
    if (!options) return;
    for (operation in options.operations) {
      var op = new Ext.data.Operation({action: operation, records: options.operations[operation]});
      this[op.action](op, Ext.emptyFn, this);
    }
  },

  read: function(operation, callback, scope) {
    this.grid.server.read(this.paramsFromOperation(operation), function(res) {
      this.processResponse(true, operation, {}, res, callback, scope);
    }, this);
    return {};
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
        // this.grid.getStore().load();
      } else {
        this.grid.netzkeNotify(errors);
      }
    }, this);
  },

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
        this.grid.netzkeNotify(errors);
      }

      // this.grid.getStore().load();

    }, this);
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
