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

// Mapping of showsAs field to grid filters
Ext.netzke.filterMap = {
	number_field:'Numeric',
	text_field:'String',
	datetime:'String',
	checkbox:'Boolean',
	combo_box:'String',
	date:'Date'
}