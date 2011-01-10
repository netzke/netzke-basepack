{
  onSearch: function(el){
    el.toggle(el.toggled); // do not toggle immediately

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
          if (win.closeRes == 'OK'){
            // var searchConditions = win.conditions;
            var filtered = true;
            // check if there's any search condition set
            // for (var k in searchConditions) {
            //   if (searchConditions[k].length > 0) {
            //     filtered = true;
            //     break;
            //   }
            // }
            el.toggle(filtered); // toggle based on the state
            // this.getStore().baseParams.extra_conditions = Ext.encode(win.conditions);
            this.getStore().baseParams.query = win.query;
            this.getStore().load();
          }
        }, this);
      }, scope: this});
    }
  }
}
