/**
 * Ext.ux.form.XCheckbox - checkbox with configurable submit values
 *
 * @author  Ing. Jozef Sakalos
 * @version $Id: Ext.ux.form.XCheckbox.js 441 2009-01-12 11:10:10Z jozo $
 * @date    10. February 2008
 *
 *
 * @license Ext.ux.form.XCheckbox is licensed under the terms of
 * the Open Source LGPL 3.0 license.  Commercial use is permitted to the extent
 * that the code/component(s) do NOT become part of another Open Source or Commercially
 * licensed development library or toolkit without explicit permission.
 *
 * License details: http://www.gnu.org/licenses/lgpl.html
 */

/*global Ext */

/**
  * @class Ext.ux.XCheckbox
  * @extends Ext.form.Checkbox
  */
Ext.ns('Ext.ux.form');
Ext.ux.form.XCheckbox = Ext.extend(Ext.form.Checkbox, {
     submitOffValue:'false'
    ,submitOnValue:'true'

    ,onRender:function() {

        this.inputValue = this.submitOnValue;

        // call parent
        Ext.ux.form.XCheckbox.superclass.onRender.apply(this, arguments);

        // create hidden field that is submitted if checkbox is not checked
        this.hiddenField = this.wrap.insertFirst({tag:'input', type:'hidden'});

        // support tooltip
        if(this.tooltip) {
            this.imageEl.set({qtip:this.tooltip});
        }

        // update value of hidden field
        this.updateHidden();

    } // eo function onRender

    /**
     * Calls parent and updates hiddenField
     * @private
     */
    ,setValue:function(v) {
        v = this.convertValue(v);
        this.updateHidden(v);
        Ext.ux.form.XCheckbox.superclass.setValue.apply(this, arguments);
    } // eo function setValue

    /**
     * Updates hiddenField
     * @private
     */
    ,updateHidden:function(v) {
        v = undefined !== v ? v : this.checked;
        v = this.convertValue(v);
        if(this.hiddenField) {
            this.hiddenField.dom.value = v ? this.submitOnValue : this.submitOffValue;
            this.hiddenField.dom.name = v ? '' : this.el.dom.name;
        }
    } // eo function updateHidden

    /**
     * Converts value to boolean
     * @private
     */
    ,convertValue:function(v) {
        return (v === true || v === 'true' || v == 1 || v === this.submitOnValue || String(v).toLowerCase() === 'on');
    } // eo function convertValue

}); // eo extend

// register xtype
Ext.reg('xcheckbox', Ext.ux.form.XCheckbox);