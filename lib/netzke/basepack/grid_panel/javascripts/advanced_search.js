{
  onSearch: function(el){
    if (this.searchWindow) {
      this.searchWindow.show();
    } else {
      this.loadComponent({name: 'search_form', callback: function(win){
        this.searchWindow = win;

        // WIP: not working because there's no baseParams anymore
        // Restore conditions in the search form
        // var currentConditionsString = this.getStore().baseParams.extra_conditions;
        // if (currentConditionsString) {
        //   win.items.first().getForm().setValues(Ext.decode(currentConditionsString));
        // }

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
  }
}
