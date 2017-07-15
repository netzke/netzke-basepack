Ext.define('Ext.data.operation.OperationsOverrided', {
    override : 'Ext.data.operation.Operation',

    initialize : function() {
        this.callOverridden(arguments);
    },

    execute: function() {
        var me = this,
            request;
        delete me.error;
        delete me.success;
        me.complete = me.exception = false;
        me.setStarted();
        me.request = request = me.doExecute();
        // Original version calls setOperation even when request doesn't have this method.
        if (request && request.setOperation) {
          request.setOperation(me);
        }
        return request;
    },
});
