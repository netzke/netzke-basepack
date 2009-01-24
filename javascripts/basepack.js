// Editors for grid cells and form fields
Ext.netzke.editors = {
  combo_box: function(c, config){
    var row = Ext.data.Record.create([{name:'id'}])
    var store = new Ext.data.Store({
      proxy: new Ext.data.HttpProxy({url:config.interface.getCbChoices, jsonData:{column:c.name}}),
      reader: new Ext.data.ArrayReader({root:'data', id:0}, row)
    })
    return new Ext.form.ComboBox({
      mode: 'remote',
      displayField:'id',
      valueField:'id',
      triggerAction:'all',
      store: store
    })
  },

  text_field: function(c, config){
    return new Ext.form.TextField({
      selectOnFocus:true
    })
  },
  
  checkbox: function(c, config){
    return new Ext.form.TextField({
      selectOnFocus:true
    })
  },
  
  number_field: function(c, config){
    return new Ext.form.NumberField({
      selectOnFocus:true
    })
  },
  
  // TODO: it's simply a text field for now
  datetime: function(c, config){
    return new Ext.form.TextField({
      selectOnFocus:true
    })
  }
};

// Mapping of editor field to grid filters
Ext.netzke.filterMap = {
  number_field:'Numeric',
  text_field:'String',
  datetime:'String',
  checkbox:'Boolean',
  combo_box:'String',
  date:'Date'
}

Ext.data.RecordArrayReader = Ext.extend(Ext.data.JsonReader, {
    /**
     * Create a data block containing Ext.data.Records from an Array.
     * @param {Object} o An Array of row objects which represents the dataset.
     * @return {Object} data A data block which is used by an Ext.data.Store object as
     * a cache of Ext.data.Records.
     */
    readRecord : function(o){
      var sid = this.meta ? this.meta.id : null;
      var recordType = this.recordType, fields = recordType.prototype.fields;
      var records = [];
      var root = o;
      // for(var i = 0; i < root.length; i++){
        var n = root;
          var values = {};
          var id = ((sid || sid === 0) && n[sid] !== undefined && n[sid] !== "" ? n[sid] : null);
          for(var j = 0, jlen = fields.length; j < jlen; j++){
                var f = fields.items[j];
                var k = f.mapping !== undefined && f.mapping !== null ? f.mapping : j;
                var v = n[k] !== undefined ? n[k] : f.defaultValue;
                v = f.convert(v, n);
                values[f.name] = v;
            }
          var record = new recordType(values, id);
          record.json = n;
      // }
      return record;
    }
});