{
  onSearch: function(el) {
    if (this.searchWindow) {
      this.searchWindow.show();
    } else {
      this.loadNetzkeComponent({name: 'search_form', callback: function(win){
        this.searchWindow = win;
        win.show();

        win.items.first().on('apply', function(){
          win.onSearch();
          return false; // do not propagate the 'apply' event
        }, this);

        win.on('hide', function(){
          var query = win.getQuery();
          if (win.closeRes == 'search'){
            var store = this.getStore(), proxy = store.getProxy();
            proxy.extraParams.query = Ext.encode(query);
            store.load();
          }
          el.toggle(query.length > 0); // toggle based on the state
        }, this);
      }, scope: this});
    }
  },

  getStore: function() {
    return this.store;
  },

  afterRender: function() {
    // delete this.record so our parent FormPanel doesn't have to load it - we do it ourselves
    var record = this.record;
    delete (this.record);

    this.callParent();

    if (record) this.store.loadRawData({records: [record], total: this.totalRecords});

    new Ext.LoadMask(this, Ext.apply(this.applyMask, {store: this.store}));
  },

  initComponent: function() {
    // Extract field names from items recursively. We have to do it before callParent(),
    // because we need to build the store for PagingToolbar that cannot be created after superclass.initComponent
    // Otherwise, the things would be simpler, because this.getForm().items would already have all the fields in one place for us
    this.fieldNames = [];
    this.extractFields(this.items);

    var store = new Ext.data.DirectStore({
      directFn: Netzke.providers[this.id].getData,
      root: 'records',
      fields: this.fieldNames.concat('_meta'),
      pageSize: 1
    });

    store.on('load', function(st, r){
      if (r.length == 0) {
        this.getForm().reset();
      } else {
        this.setFormValues(r[0].data);
      }
    }, this);

    this.bbar = Ext.create('Ext.toolbar.Paging', {
      beforePageText: "Record",
      store: store,
      items: ["-"].concat(this.bbar || [])
    });

    this.store = store;

    this.callParent();
  }
}
