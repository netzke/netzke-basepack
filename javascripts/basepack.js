Ext.ns("Netzke.pre");
Ext.ns("Netzke.pre.Basepack");
Ext.ns("Ext.ux.grid");

Ext.util.Format.mask = function(v){
  return "********";
};

Ext.define('Ext.ux.form.TriCheckbox', {
  extend: 'Ext.form.field.ComboBox',
  alias: 'widget.tricheckbox',
  store: [[true, "Yes"], [false, "No"]],
  forceSelection: true
});

// Fix race condition with Ext JS 5.1.0 (while testing)
// The error was: "Ext.EventObject is undefined"
// Looks like Ext.EventObject is a legacy artifact in Ext JS 5, as it can be found only twice in the whole code base,
// so, it probably gets removed in one of the next releases.
Ext.override(Ext.view.BoundList, {
  onHide: function() {
    var inputEl = this.pickerField.inputEl.dom;
    if (Ext.Element.getActiveElement() !== inputEl) {
      inputEl.focus();
    }
    this.callParent(arguments);
  },
});
