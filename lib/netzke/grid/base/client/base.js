/**
 * Client-side code for [Netzke::Grid::Base](http://www.rubydoc.info/github/netzke/netzke-basepack/Netzke/Grid/Base)
 * @class Netzke.Grid.Base
 */
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

    this.store = this.netzkeBuildStore();

    // Cell editing
    if (this.netzkePermits('update') || this.netzkePermits('create') && this.editsInline) {
      this.plugins.push(Ext.create('Ext.grid.plugin.CellEditing', {pluginId: 'celleditor'}));
    }

    // Toolbar
    this.dockedItems = this.dockedItems || [];
    if (this.paging == 'pagination') {
      this.dockedItems.push({
        xtype: 'pagingtoolbar',
        dock: 'bottom',
        listeners: {
          'beforechange': this.disableDirtyPageWarning ? {} : {fn: this.netzkeBeforePageChange, scope: this}
        },
        store: this.store,
        items: this.bbar && ["-"].concat(this.bbar)
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
      this.on('itemcontextmenu', this.netzkeOnItemContextMenu, this);
    }

    this.netzkeSetActionEvents();

    // When starting editing as assocition column, pre-load the combobox store from the meta column, so that we don't see the real value of this cell (the id of the associated record), but rather the associated record by the configured method.
    this.on('beforeedit', function(editor, e){
      if (e.column.assoc && e.column.getEditor()) {
        var c = e.column,
        combo = c.getEditor(),
        store = combo.store,
        id = e.record.get(e.field);

        // initial load of 1 single record for the combobox store, which contains the display text (stored in the meta field) for the current value
        if (id && -1 == store.find('value', id)) {
          store.loadData([[e.record.get(e.field), e.record.get('association_values')[e.field]]], true);
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
      // if autoSync is enabled, cancel event and call netzkeOnApply() instead
      this.getStore().on('beforesync', function(){
        this.netzkeOnApply();
        return false;
      }, this);
    }

    this.on('itemdblclick', this.netzkeHandleItemdblclick, this);
    this.on('beforeedit', this.netzkeHandleBeforeEdit, this);

    // Remember grid selection on reloads
    if(this.netzkeRememberSelection && this.netzkeRestoreSelection){
      this.getStore().on('beforeload', this.netzkeRememberSelection, this);
      this.getView().on('refresh', this.netzkeRestoreSelection, this);
    }
  },

  /**
   * @method netzkeBuildStore
   * @return {Ext.data.Store} Pre-configured instance of the store
   */
  netzkeBuildStore: function() {
    var store = Ext.create('Ext.data.Store', this.netzkeStoreConfig());

    delete this.dataStore;

    store.getProxy().getReader().on('endpointcommands', function(commands) {
      this.netzkeBulkExecute(commands);
    }, this);

    this.netzkeApplyStoreBugfixes(store)

    return store;
  },

  // Modifies store, to avoid bugs in Ext.js
  netzkeApplyStoreBugfixes: function(store) {
    store.totalCount = store.totalCount === undefined ? 0 : store.totalCount;

    store._oldGetRange = store.getRange
    store.getRange = function(start, end, options) {
      var newEnd;
      var newStart = start === undefined ? 0 : start;

      if (end !== undefined) { newEnd = end }
      else if (this.totalCount !== undefined) { newEnd = this.totalCount }
      else { newEnd = 0 }

      return this._oldGetRange(newStart, newEnd, options)
    }

    // When store is empty
    store._oldRangeCached = store.rangeCached;

    store.rangeCached = function(start, end) {
      var newEnd = end < 0 ? 0 : end;
      return this._oldRangeCached(start, newEnd);
    }

    store.prefetch = this.prefetchFix;

    return store
  },

  /**
   * @method netzkeStoreConfig
   * @return {Object} Configuration for the store
   */
  netzkeStoreConfig: function(){
    var defaults = {
      proxy: this.netzkeBuildProxy(),
      fields: this.fields,
      pruneModifiedRecords: true,
      remoteSort: true,
      remoteFilter: true,
      buffered: this.paging == 'buffered'
    };

    if (this.paging == 'buffered') { defaults.pageSize = 300; }

    if (this.paging == 'none') { defaults.pageSize = 0; }

    return Ext.apply({}, this.storeConfig, defaults);
  },

  /**
   * @method netzkeBuildProxy
   * @return {Netzke.Grid.Proxy} Instance of the data proxy
   */
  netzkeBuildProxy: function() {
    return Ext.create('Netzke.Grid.Proxy', this.netzkeProxyConfig());
  },

  /**
   * @method netzkeProxyConfig
   * @return {Object} configuration for data proxy
   */
  netzkeProxyConfig: function(){
    return {
      reader: this.netzkeBuildReader(),
      grid: this
    }
  },

  /**
   * @method netzkeBuildReader
   * @return {Netzke.Grid.ArrayReader} Instance of the data reader
   */
  netzkeBuildReader: function() {
    return Ext.create('Netzke.Grid.ArrayReader');
  },

  /**
   * Called before user navigates from page in the grid
   * @method netzkeBeforePageChange
   * @return {Boolean} Browser confirmation popup result
   */
  netzkeBeforePageChange: function(){
    var store = this.getStore();
    if (store.getNewRecords().length > 0 || store.getModifiedRecords().length > 0) {
      return confirm(this.i18n.proceedWithUnappliedChanges);
    }
  },

  prefetchFix: function(options) {
    var me = this,
      pageSize = me.getPageSize(),
      data = me.getData(),
      operation, existingPageRequest;
    // Check pageSize has not been tampered with. That would break page caching
    if (pageSize) {
      if (me.lastPageSize && pageSize != me.lastPageSize) {
        Ext.raise("pageSize cannot be dynamically altered");
      }
      if (!data.getPageSize()) {
        data.setPageSize(pageSize);
      }
    } else // Allow first prefetch call to imply the required page size.
    {
      me.pageSize = data.setPageSize(pageSize = options.limit);
    }
    // So that we can check for tampering next time through
    me.lastPageSize = pageSize;
    // Always get whole pages.
    if (!options.page) {
      options.page = me.getPageFromRecordIndex(options.start);
      options.start = (options.page - 1) * pageSize;
      options.limit = Math.ceil(options.limit / pageSize) * pageSize;
    }
    // Currently not requesting this page, or the request was for the last
    // generation of the data cache (clearing it changes generations)
    // then request it...
    existingPageRequest = me.pageRequests[options.page];
    pageMapGeneraton = existingPageRequest && existingPageRequest.getOperation && existingPageRequest.getOperation().pageMapGeneration !== data.pageMapGeneration;

    if (!existingPageRequest || pageMapGeneraton) {
      // Copy options into a new object so as not to mutate passed in objects
      options = Ext.apply({
        action: 'read',
        filters: me.getFilters().items,
        sorters: me.getSorters().items,
        grouper: me.getGrouper(),
        internalCallback: me.onProxyPrefetch,
        internalScope: me
      }, options);
      operation = me.createOperation('read', options);
      // Generation # of the page map to which the requested records belong.
      // If page map is cleared while this request is in flight, the pageMapGeneration will increment and the payload will be rejected
      operation.pageMapGeneration = data.pageMapGeneration;
      if (me.fireEvent('beforeprefetch', me, operation) !== false) {
        me.pageRequests[options.page] = operation.execute();
        if (me.getProxy().isSynchronous) {
          delete me.pageRequests[options.page];
        }
      }
    }
    return me;
  }
}
