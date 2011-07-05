{
  onSearch: function(el) {
    if (this.searchWindow) {
      this.searchWindow.show();
    } else {
      this.loadComponent({name: 'search_form', callback: function(win){
        this.searchWindow = win;
        var currentConditionsString = this.getStore().baseParams.extra_conditions;
        if (currentConditionsString) {
          win.items.first().getForm().setValues(Ext.decode(currentConditionsString));
        }

        win.items.first().on('apply', function(){
          win.onSearch();
          return false; // do not propagate the 'apply' event
        }, this);

        win.on('hide', function(){
          var query = win.getQuery();
          if (win.closeRes == 'search'){
            this.getStore().baseParams.query = Ext.encode(query);
            this.getStore().load();
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
    this.callParent();

    // WIP: commented out because it produces error otherwise:
    //   el is undefined
    //   http://nbt.local/extjs4/ext-all-debug.js?1305798122
    //   Line 18214"
    //          new Ext.LoadMask(this.bwrap, Ext.apply(this.applyMask, {store: this.store}));
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
      pageSize: 1,
      // HACK: we must let the store know totalCount, but this property is not public (yet?)
      totalCount: this.totalRecords
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