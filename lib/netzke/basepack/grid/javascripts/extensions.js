/**
 * Extended Ext.data.reader.Array, which can handle commands from the endpoint, and fires the 'endpointcommands' event
 * when commands are present in the endpoint response
 */
Ext.define('Netzke.classes.Basepack.Grid.ArrayReader', {
  extend: 'Ext.data.reader.Array',
  root: 'data',
  totalProperty: 'total',
  constructor: function() {
    this.callParent(arguments);
    this.addEvents('endpointcommands');
  },
  read: function(response) {
    var data = {data: response.data, total: response.total};
    delete(response.data);
    delete(response.total);
    this.fireEvent('endpointcommands', response);
    return this.callParent([data]);
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
