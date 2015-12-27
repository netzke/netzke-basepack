Ext.define('Ext.netzke.Tristate', {
  extend: 'Ext.form.FieldContainer',
  alias: 'widget.netzketristate',
  layout: 'hbox',

  mixins: {
    field: 'Ext.form.field.Field'
  },

  setValue: function(value){
    if (this.value != value) this.triggerValue(value);
  },

  getValue: function(){
    return this.value == undefined ? "" : this.value;
  },

  items: [{
    xtype: 'menucheckitem',
    checked: true,
    text: '&nbsp;',
    itemId: 'item-true',
    cls: "x-btn-default-toolbar-small nz-btn-tristate",
    activeCls: "",
    listeners: {
      render: function(){
        var el = this.getEl(), me = this;
        el.on('click', function(e){
          e.preventDefault();
          me.ownerCt.triggerValue(true);
        })
      }
    }
  },{
    xtype: 'menucheckitem',
    checked: false,
    itemId: 'item-false',
    text: '&nbsp;',
    cls: "x-btn-default-toolbar-small nz-btn-tristate",
    activeCls: "",
    listeners: {
      render: function(){
        var el = this.getEl(), me = this;
        el.on('click', function(e){
          e.preventDefault();
          me.ownerCt.triggerValue(false);
        })
      }
    }
  }],

  triggerValue: function(val){
    if (this.value == val) {
      this.getComponent("item-" + val).removeCls('nz-tristate-selected');
      this.value = undefined;
    } else {
      this.getComponent("item-" + val).addCls('nz-tristate-selected');
      this.getComponent("item-" + !val).removeCls('nz-tristate-selected');
      this.value = val;
    }
  }
});
