{
  onEditInForm: function(){
    var selModel = this.getSelectionModel();
    if (selModel.getCount() > 1) {
      var recordId = selModel.selected.first().getId();
      this.loadNetzkeComponent({name: "multi_edit_form",
        params: {record_id: recordId},
        callback: function(w){
          w.show();
          var form = w.items.first();
          form.on('apply', function(){
            var ids = [];
            selModel.selected.each(function(r){
              ids.push(r.getId());
            });
            if (!form.baseParams) form.baseParams = {};
            form.baseParams.ids = Ext.encode(ids);
          }, this);

          w.on('close', function(){
            if (w.closeRes === "ok") {
              this.store.load();
            }
          }, this);
        }, scope: this});
    } else {
      var recordId = selModel.selected.first().getId();
      this.loadNetzkeComponent({name: "edit_form",
        params: {record_id: recordId},
        callback: function(w){
          w.show();
          w.on('close', function(){
            if (w.closeRes === "ok") {
              this.store.load();
            }
          }, this);
        }, scope: this});
    }
  },

  onAddInForm: function(){
    this.loadNetzkeComponent({name: "add_window", callback: function(w){
      w.show();
      w.on('close', function(){
        if (w.closeRes === "ok") {
          this.store.load();
        }
      }, this);
    }, scope: this});
  }
}
