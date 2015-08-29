{
  multiSelect: true,

  initComponent: function(){
    // if we are being created by the locking feature - everything is configured already, nothing to do
    if (this.isLocked) return this.callParent();

    this.plugins = this.plugins || [];

    // Enable filters feature
    this.plugins.push('gridfilters');

    // Normalize columns. Extract data fields and meta column.
    this.netzkeProcessColumns();

    // Prepare column model config with columns in the correct order; columns out of order go to the end.
    var colModelConfig = [];
    var columns = this.columns;

    Ext.each(this.columnsOrder, function(c) {
      var mainColConfig;
      Ext.each(this.columns.items, function(oc) {
        if (c.name === oc.name) {
          mainColConfig = Ext.apply({}, oc);
          return false;
        }
      });

      colModelConfig.push(Ext.apply(mainColConfig, c));
    }, this);

    this.columns.items = colModelConfig;

    // data store
    this.store = this.netzkeBuildStore(this.config.infiniteScrolling);

    // Cell editing
    if (!this.prohibitUpdate && this.editInline) {
      this.plugins.push(Ext.create('Ext.grid.plugin.CellEditing', {pluginId: 'celleditor'}));
    }

    // Toolbar
    this.dockedItems = this.dockedItems || [];
    if (this.enablePagination && !this.config.infiniteScrolling) {
      this.dockedItems.push({
        xtype: 'pagingtoolbar',
        dock: 'bottom',
        store: this.store,
        items: this.bbar && ["-"].concat(this.bbar) // append the passed bbar
      });
    } else if (this.bbar) {
      this.dockedItems.push({
        xtype: 'toolbar',
        dock: 'bottom',
        items: this.bbar
      });
    }

    delete this.bbar;

    this.callParent();

    // Context menu
    if (this.contextMenu) {
      this.on('itemcontextmenu', this.onItemContextMenu, this);
    }

    // Disabling/enabling editInForm button according to current selection
    if (!this.prohibitUpdate) {
      this.getSelectionModel().on('selectionchange', function(selModel, selected){
        var disabled;
        if (selected === undefined || selected.length === 0) { // empty?
          disabled = true;
        } else {
          // Disable "edit in form" button if new record is present in selection
          Ext.each(selected, function(r){
            if (r.isNew) { disabled = true; return false; }
          });
        };
        this.actions.edit.setDisabled(disabled);
      }, this);
    }

    // Process selectionchange event to enable/disable actions
    this.getSelectionModel().on('selectionchange', function(selModel){
      if (this.actions.del) this.actions.del.setDisabled(!selModel.hasSelection() || this.prohibitDelete);
      if (this.actions.edit) this.actions.edit.setDisabled(this.prohibitUpdate);
    }, this);

    // When starting editing as assocition column, pre-load the combobox store from the meta column, so that we don't see the real value of this cell (the id of the associated record), but rather the associated record by the configured method.
    this.on('beforeedit', function(editor, e){
      if (e.column.assoc && e.record.get('meta') && e.column.getEditor()) {
        var c = e.column,
        combo = c.getEditor(),
        store = combo.store,
        id = e.record.get(e.field);

        // initial load of 1 single record for the combobox store, which contains the display text (stored in the meta field) for the current value
        if (id && -1 == store.find('value', id)) {
          store.loadData([[e.record.get(e.field), e.record.get('meta').associationValues[e.field]]], true);
        }

      }
    }, this);

    this.on('afterlayout', function() {
      // Persistence-related events (afterrender to avoid blank event firing on render)
      if (this.persistence) {
        // Inform the server part about column operations
        this.on('columnresize', this.netzkeSaveColumns, this);
        this.on('columnmove', this.netzkeSaveColumns, this);
        this.on('columnhide', this.netzkeSaveColumns, this);
        this.on('columnshow', this.netzkeSaveColumns, this);
      }
    }, this);

    if(this.getStore().autoSync){
      // if autoSync is enabled, cancel event and call onApply() instead
      this.getStore().on('beforesync', function(){
        this.onApply();
        return false;
      }, this);
    }

    // If edit in form is enabled, but edit in cell is disabled, change double-click to edit in form
    if (!this.editInline) {
      this.on('itemdblclick', function(view, record) {
        this.doEditInForm(record);
      }, this);
    }

    // Remember grid selection on reloads
    if(this.netzkeRememberSelection && this.netzkeRestoreSelection){
      this.getStore().on('beforeload', this.netzkeRememberSelection, this);
      this.getView().on('refresh', this.netzkeRestoreSelection, this);
    }
  },


  netzkeBuildStore: function(buffered) {
    var buffered = buffered || false;
    var store = Ext.create('Ext.data.Store', Ext.apply({
      fields: this.fields,
      proxy: this.netzkeBuildProxy(),
      pruneModifiedRecords: true,
      remoteSort: true,
      remoteFilter: true,
      pageSize: this.rowsPerPage,
      autoLoad: true,
      buffered: buffered,
      reload: this.netzkeStoreReload
    }, this.dataStore));

    delete this.dataStore;

    store.getProxy().getReader().on('endpointcommands', function(commands) {
      this.netzkeBulkExecute(commands);
    }, this);

    return store;
  },

  netzkeBuildProxy: function() {
    return Ext.create('Netzke.Basepack.Grid.Proxy', {
      reader: this.netzkeBuildReader(),
      grid: this
    });
  },

  netzkeBuildReader: function() {
    return Ext.create('Netzke.Basepack.Grid.ArrayReader');
  },

  netzkeStoreReload: function(options) {
    var me = this,
      startIdx, endIdx, startPage, endPage, i, waitForReload, bufferZone, records,
      data = me.getData();

    if (me.loading) {
      return;
    }
    if (!options) {
      options = {};
    }

    delete me.totalCount;

    data.clear(true);
    waitForReload = function () {
      if (me.rangeCached(startIdx, Math.min(endIdx, me.getTotalCount()))) {
        me.loading = false;
        data.un('pageadd', waitForReload);
        // Hack fixing the exception on last page load
        records = data.getRange(startIdx, Math.min(endIdx + 1, me.getTotalCount()));
        me.fireEvent('load', me, records, true);
        me.fireEvent('refresh', me);
      }
    };
    bufferZone = Math.ceil((me.getLeadingBufferZone() + me.getTrailingBufferZone()) / 2);

    if (!me.lastRequestStart) {
      startIdx = options.start || 0;
      endIdx = startIdx + (options.count || me.getPageSize()) - 1;
    } else {
      startIdx = me.lastRequestStart;
      endIdx = me.lastRequestEnd;
    }

    startIdx = Math.max(startIdx - bufferZone, 0);
    endIdx += bufferZone;
    startPage = me.getPageFromRecordIndex(startIdx);
    endPage = me.getPageFromRecordIndex(endIdx);
    if (me.fireEvent('beforeload', me, options) !== false) {
      me.loading = true;


      data.on('pageadd', waitForReload);

      for (i = startPage; i <= endPage; i++) {
        me.prefetchPage(i, options);
      }
    }
  },
}
