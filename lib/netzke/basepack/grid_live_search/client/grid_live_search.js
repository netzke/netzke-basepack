{
  init: function(cmp){
    this.searchControls = cmp.query('field[attr]');

    Ext.each(this.searchControls, function(control){
      control.on('change', Ext.Function.createBuffered(function(self){
        var query = this.buildQuery();
        cmp.getStore().getProxy().extraParams.query = [query];
        cmp.nzReloadStore();
      }, this.delay || 500, this));
    }, this);
  },

  buildQuery: function(){
    var query = [];
    Ext.each(this.searchControls, function(f){
      var value = f.getValue();
      if (value) query.push({attr: f.attr, value: value, operator: f.op});
    });
    return query;
  }
}
