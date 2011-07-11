Ext.ns("Netzke.pre");
Ext.ns("Netzke.pre.Basepack");
Ext.ns("Ext.ux.grid");

Ext.apply(Ext.History, new Ext.util.Observable());

// A convenient passfield
Ext.netzke.PassField = Ext.extend(Ext.form.TextField, {
  inputType: 'password'
});
Ext.reg('passfield', Ext.netzke.PassField);

Ext.override(Ext.ux.form.DateTimeField, {
  format: "Y-m-d",
  timeFormat: "g:i:s",
  picker: {
    minIncremenet: 15
  }
});

// ComboBox that gets options from the server (used in both grids and panels)
Ext.netzke.ComboBox = Ext.extend(Ext.form.ComboBox, {
  valueField    : 'field1',
  displayField  : 'field2',
  triggerAction : 'all',
  typeAhead     : true,

  initComponent : function(){
    var row = Ext.data.Record.create(['field1', 'field2']); // defaults for local ComboBox; makes testing easier
    var store = new Ext.data.Store({
      proxy         : new Ext.data.DirectProxy({directFn: Netzke.providers[this.parentId].getComboboxOptions}),
      reader        : new Ext.data.ArrayReader({root:'data', id:0}, row)
    });
    store.proxy.on('beforeload', function (self, params) {
      params.column = this.name;
    },this);

    if (this.store) store.loadData({data: this.store});

    this.store = store;

    Ext.netzke.ComboBox.superclass.initComponent.apply(this, arguments);

    var parent = Ext.getCmp(this.parentId);
    // Is parent a grid?
    if (parent.getSelectionModel) {
      this.on('beforequery',function(qe) {
        delete qe.combo.lastQuery;
      },this);
    }

    // A not-so-clean approach to submit the current record id
    store.on('beforeload',function(store, options){
      if (parent.getSelectionModel) {
        var selected = parent.getSelectionModel().getSelected();
        if (selected) options.params.id = selected.id;
      } else {
        // TODO: also for the FormPanel
      }
    }, this);
  }
});

Ext.reg('netzkeremotecombo', Ext.netzke.ComboBox);

Ext.util.Format.mask = function(v){
  return "********";
};

Ext.netzke.JsonField = Ext.extend(Ext.form.TextField, {
  validator: function(value) {
    try{
      var d = Ext.decode(value);
      return true;
    } catch(e) {
      return "Invalid JSON"
    }
  }

  ,setValue: function(value) {
    this.setRawValue(Ext.encode(value));
  }

});

Ext.reg('jsonfield', Ext.netzke.JsonField);

Ext.grid.HeaderDropZone.prototype.onNodeDrop = function(n, dd, e, data){
    var h = data.header;
    if(h != n){
        var cm = this.grid.colModel;
        var x = Ext.lib.Event.getPageX(e);
        var r = Ext.lib.Dom.getRegion(n.firstChild);
        var pt = (r.right - x) <= ((r.right-r.left)/2) ? "after" : "before";
        var oldIndex = this.view.getCellIndex(h);
        var newIndex = this.view.getCellIndex(n);
        if(pt == "after"){
            newIndex++;
        }
        if(oldIndex < newIndex){
            newIndex--;
        }
        cm.moveColumn(oldIndex, newIndex);
        return true;
    }
    return false;
};


Ext.ns('Ext.ux.form');
Ext.ux.form.TriCheckbox = Ext.extend(Ext.form.ComboBox, {
  store: [[true, "true"], [false, "false"]],
  forceSelection: true,
  triggerAction: 'all'
});
Ext.reg('tricheckbox', Ext.ux.form.TriCheckbox);


// Enabling checkbox submission when unchecked
(function() {
  origCheckboxRender = Ext.form.Checkbox.prototype.onRender;
  origCheckboxSetValue = Ext.form.Checkbox.prototype.setValue;

  Ext.override(Ext.form.Checkbox, {
    onRender: function() {
      // call the original onRender() function
      origCheckboxRender.apply(this, arguments);

      if (this.getXType() === 'radio') return;

      // Handle initial case based on this.checked
      if (this.checked == false) {
        this.noValEl = Ext.DomHelper.insertAfter(this.el, {
            tag: 'input',
            type: 'hidden',
            value: false,
            name: this.getName()
        }, true);
      }
      else {
        this.noValEl = null;
      }
    },
    setValue: function() {
      // call original setValue() function
      origCheckboxSetValue.apply(this, arguments);

      if (this.getXType() === 'radio') return;

      if (this.checked) {
        if (this.noValEl != null) {
          // Remove the extra hidden element
          this.noValEl.remove();
          this.noValEl = null;
        }
      }
      else {
        // Add our hidden element for (unchecked) value
        if (this.noValEl == null) this.noValEl = Ext.DomHelper.insertAfter(this.el, {
            tag: 'input',
            type: 'hidden',
            value: false,
            name: this.getName()
        }, true);
      }
    }
  });
})();
