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
	
	datetime: function(c, config){
		return new Ext.form.TextField({
			selectOnFocus:true
		})
	}
}