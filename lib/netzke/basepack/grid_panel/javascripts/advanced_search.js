{
  onSearch: function(el){
    el.toggle(el.toggled); // do not toggle immediately

    this.loadComponent({name: 'search_form', callback: function(win){
      var currentConditionsString = this.getStore().baseParams.extra_conditions;
      if (currentConditionsString) {
        win.items.first().getForm().setValues(Ext.decode(currentConditionsString));
      }

      win.items.first().on('apply', function(){
        win.onSearch();
        return false; // do not propagate the 'apply' event
      }, this);

      win.on('close', function(){
        if (win.closeRes == 'OK'){
          var searchConditions = win.conditions;
          var filtered = false;
          // check if there's any search condition set
          for (var k in searchConditions) {
            if (searchConditions[k].length > 0) {
              filtered = true;
              break;
            }
          }
          el.toggle(filtered); // toggle based on the state
          this.getStore().baseParams.extra_conditions = Ext.encode(win.conditions);
          this.getStore().load();
        }
      }, this);
    }, scope: this});
  }
}
