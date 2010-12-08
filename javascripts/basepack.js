Ext.ns("Netzke.pre");
Ext.ns("Netzke.pre.Basepack");
Ext.ns("Ext.ux.grid");

Ext.apply(Ext.History, new Ext.util.Observable());

// A convenient passfield
Ext.netzke.PassField = Ext.extend(Ext.form.TextField, {
  inputType: 'password'
});
Ext.reg('passfield', Ext.netzke.PassField);

// ComboBox that gets options from the server (used in both grids and panels)
Ext.netzke.ComboBox = Ext.extend(Ext.form.ComboBox, {
  displayField  : 'id',
  valueField    : 'id',
  triggerAction : 'all',
  typeAhead     : true,

  initComponent : function(){
    var row = Ext.data.Record.create([{name:'id'}]);
    var store = new Ext.data.Store({
      proxy         : new Ext.data.HttpProxy({url: Ext.getCmp(this.parentId).endpointUrl("get_combobox_options"), jsonData:{column:this.name}}),
      reader        : new Ext.data.ArrayReader({root:'data', id:0}, row)
    });

    Ext.apply(this, {
      store : store
    });

    Ext.netzke.ComboBox.superclass.initComponent.apply(this, arguments);

    this.on('blur', function(cb){
      cb.setValue(cb.getRawValue());
    });

    this.on('specialkey', function(cb, event){
      if (event.getKey() == 9 || event.getKey() == 13) {cb.setValue(cb.getRawValue());}
    });

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
        if (selected) options.params.id = selected.get('id');
      } else {
        // TODO: also for the FormPanel
      }
    },this)
  }
});

Ext.reg('combobox', Ext.netzke.ComboBox);

Ext.util.Format.mask = function(v){
  return "********";
};

// Implementation of totalProperty, successProperty and root configuration options for ArrayReader
Ext.data.ArrayReader = Ext.extend(Ext.data.JsonReader, {
  readRecords : function(o){
    var sid = this.meta ? this.meta.id : null;
    var recordType = this.recordType, fields = recordType.prototype.fields;
    var records = [];
    var root = o[this.meta.root] || o, totalRecords = o[this.meta.totalProperty], success = o[this.meta.successProperty];
    for(var i = 0; i < root.length; i++){
      var n = root[i];
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
      records[records.length] = record;
    }
    return {
      records : records,
      totalRecords : totalRecords,
      success : success
    };
  }
});


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
    return record;
  }
});

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

/**
 * @class Ext.ux.form.DateTime
 * @extends Ext.form.Field
 *
 * DateTime field, combination of DateField and TimeField
 *
 * @author      Ing. Jozef Sak�lo�
 * @copyright (c) 2008, Ing. Jozef Sak�lo�
 * @version   2.0
 * @revision  $Id: Ext.ux.form.DateTime.js 513 2009-01-29 19:59:22Z jozo $
 *
 * @license Ext.ux.form.DateTime is licensed under the terms of
 * the Open Source LGPL 3.0 license.  Commercial use is permitted to the extent
 * that the code/component(s) do NOT become part of another Open Source or Commercially
 * licensed development library or toolkit without explicit permission.
 *
 * <p>License details: <a href="http://www.gnu.org/licenses/lgpl.html"
 * target="_blank">http://www.gnu.org/licenses/lgpl.html</a></p>
 *
 * @forum      22661
 */

Ext.ns('Ext.ux.form');

/**
 * @constructor
 * Creates new DateTime
 * @param {Object} config The config object
 */
Ext.ux.form.DateTime = Ext.extend(Ext.form.Field, {
    /**
     * @cfg {String/Object} defaultAutoCreate DomHelper element spec
     * Let superclass to create hidden field instead of textbox. Hidden will be submittend to server
     */
     defaultAutoCreate:{tag:'input', type:'hidden'}
    /**
     * @cfg {Number} timeWidth Width of time field in pixels (defaults to 100)
     */
    ,timeWidth:80
    /**
     * @cfg {String} dtSeparator Date - Time separator. Used to split date and time (defaults to ' ' (space))
     */
    ,dtSeparator:' '
    /**
     * @cfg {String} hiddenFormat Format of datetime used to store value in hidden field
     * and submitted to server (defaults to 'Y-m-d H:i:s' that is mysql format)
     */
    ,hiddenFormat:'Y-m-d H:i:s'
    /**
     * @cfg {Boolean} otherToNow Set other field to now() if not explicly filled in (defaults to true)
     */
    ,otherToNow:true
    /**
     * @cfg {Boolean} emptyToNow Set field value to now on attempt to set empty value.
     * If it is true then setValue() sets value of field to current date and time (defaults to false)
     */
    /**
     * @cfg {String} timePosition Where the time field should be rendered. 'right' is suitable for forms
     * and 'below' is suitable if the field is used as the grid editor (defaults to 'right')
     */
    ,timePosition:'right' // valid values:'below', 'right'
    /**
     * @cfg {String} dateFormat Format of DateField. Can be localized. (defaults to 'm/y/d')
     */
    ,dateFormat:'m/d/y'
    /**
     * @cfg {String} timeFormat Format of TimeField. Can be localized. (defaults to 'g:i A')
     */
    ,timeFormat:'g:i A'
    /**
     * @cfg {Object} dateConfig Config for DateField constructor.
     */
    /**
     * @cfg {Object} timeConfig Config for TimeField constructor.
     */

    // {{{
    /**
     * @private
     * creates DateField and TimeField and installs the necessary event handlers
     */
    ,initComponent:function() {
        // call parent initComponent
        Ext.ux.form.DateTime.superclass.initComponent.call(this);

        // create DateField
        var dateConfig = Ext.apply({}, {
             id:this.id + '-date'
            ,format:this.dateFormat || Ext.form.DateField.prototype.format
            ,width:this.timeWidth
            ,selectOnFocus:this.selectOnFocus
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.dateConfig);
        this.df = new Ext.form.DateField(dateConfig);
        this.df.ownerCt = this;
        delete(this.dateFormat);


        // create TimeField
        var timeConfig = Ext.apply({}, {
             id:this.id + '-time'
            ,format:this.timeFormat || Ext.form.TimeField.prototype.format
            ,width:this.timeWidth
            ,selectOnFocus:this.selectOnFocus
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.timeConfig);
        this.tf = new Ext.form.TimeField(timeConfig);
        this.tf.ownerCt = this;
        delete(this.timeFormat);

        // relay events
        this.relayEvents(this.df, ['focus', 'specialkey', 'invalid', 'valid']);
        this.relayEvents(this.tf, ['focus', 'specialkey', 'invalid', 'valid']);

    } // eo function initComponent
    // }}}
    // {{{
    /**
     * @private
     * Renders underlying DateField and TimeField and provides a workaround for side error icon bug
     */
    ,onRender:function(ct, position) {
        // don't run more than once
        if(this.isRendered) {
            return;
        }

        // render underlying hidden field
        Ext.ux.form.DateTime.superclass.onRender.call(this, ct, position);

        // render DateField and TimeField
        // create bounding table
        var t;
        if('below' === this.timePosition || 'bellow' === this.timePosition) {
            t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
                 {tag:'tr',children:[{tag:'td', style:'padding-bottom:1px', cls:'ux-datetime-date'}]}
                ,{tag:'tr',children:[{tag:'td', cls:'ux-datetime-time'}]}
            ]}, true);
        }
        else {
            t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
                {tag:'tr',children:[
                    {tag:'td',style:'padding-right:4px', cls:'ux-datetime-date'},{tag:'td', cls:'ux-datetime-time'}
                ]}
            ]}, true);
        }

        this.tableEl = t;
//        this.wrap = t.wrap({cls:'x-form-field-wrap'});
        this.wrap = t.wrap();
        this.wrap.on("mousedown", this.onMouseDown, this, {delay:10});

        // render DateField & TimeField
        this.df.render(t.child('td.ux-datetime-date'));
        this.tf.render(t.child('td.ux-datetime-time'));

        // workaround for IE trigger misalignment bug
        if(Ext.isIE && Ext.isStrict) {
            t.select('input').applyStyles({top:0});
        }

        this.on('specialkey', this.onSpecialKey, this);
        this.df.el.swallowEvent(['keydown', 'keypress']);
        this.tf.el.swallowEvent(['keydown', 'keypress']);

        // create icon for side invalid errorIcon
        if('side' === this.msgTarget) {
            var elp = this.el.findParent('.x-form-element', 10, true);
            this.errorIcon = elp.createChild({cls:'x-form-invalid-icon'});

            this.df.errorIcon = this.errorIcon;
            this.tf.errorIcon = this.errorIcon;
        }

        // setup name for submit
        this.el.dom.name = this.hiddenName || this.name || this.id;

        // prevent helper fields from being submitted
        this.df.el.dom.removeAttribute("name");
        this.tf.el.dom.removeAttribute("name");

        // we're rendered flag
        this.isRendered = true;

        // update hidden field
        this.updateHidden();

    } // eo function onRender
    // }}}
    // {{{
    /**
     * @private
     */
    ,adjustSize:Ext.BoxComponent.prototype.adjustSize
    // }}}
    // {{{
    /**
     * @private
     */
    ,alignErrorIcon:function() {
        this.errorIcon.alignTo(this.tableEl, 'tl-tr', [2, 0]);
    }
    // }}}
    // {{{
    /**
     * @private initializes internal dateValue
     */
    ,initDateValue:function() {
        this.dateValue = this.otherToNow ? new Date() : new Date(1970, 0, 1, 0, 0, 0);
    }
    // }}}
    // {{{
    /**
     * Calls clearInvalid on the DateField and TimeField
     */
    ,clearInvalid:function(){
        this.df.clearInvalid();
        this.tf.clearInvalid();
    } // eo function clearInvalid
    // }}}
    // {{{
    /**
     * @private
     * called from Component::destroy.
     * Destroys all elements and removes all listeners we've created.
     */
    ,beforeDestroy:function() {
        if(this.isRendered) {
//            this.removeAllListeners();
            this.wrap.removeAllListeners();
            this.wrap.remove();
            this.tableEl.remove();
            this.df.destroy();
            this.tf.destroy();
        }
    } // eo function beforeDestroy
    // }}}
    // {{{
    /**
     * Disable this component.
     * @return {Ext.Component} this
     */
    ,disable:function() {
        if(this.isRendered) {
            this.df.disabled = this.disabled;
            this.df.onDisable();
            this.tf.onDisable();
        }
        this.disabled = true;
        this.df.disabled = true;
        this.tf.disabled = true;
        this.fireEvent("disable", this);
        return this;
    } // eo function disable
    // }}}
    // {{{
    /**
     * Enable this component.
     * @return {Ext.Component} this
     */
    ,enable:function() {
        if(this.rendered){
            this.df.onEnable();
            this.tf.onEnable();
        }
        this.disabled = false;
        this.df.disabled = false;
        this.tf.disabled = false;
        this.fireEvent("enable", this);
        return this;
    } // eo function enable
    // }}}
    // {{{
    /**
     * @private Focus date filed
     */
    ,focus:function() {
        this.df.focus();
    } // eo function focus
    // }}}
    // {{{
    /**
     * @private
     */
    ,getPositionEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * @private
     */
    ,getResizeEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * @return {Date/String} Returns value of this field
     */
    ,getValue:function() {
        // create new instance of date
        return this.dateValue ? new Date(this.dateValue) : '';
    } // eo function getValue
    // }}}
    // {{{
    /**
     * @return {Boolean} true = valid, false = invalid
     * @private Calls isValid methods of underlying DateField and TimeField and returns the result
     */
    ,isValid:function() {
        return this.df.isValid() && this.tf.isValid();
    } // eo function isValid
    // }}}
    // {{{
    /**
     * Returns true if this component is visible
     * @return {boolean}
     */
    ,isVisible : function(){
        return this.df.rendered && this.df.getActionEl().isVisible();
    } // eo function isVisible
    // }}}
    // {{{
    /**
     * @private Handles blur event
     */
    ,onBlur:function(f) {
        // called by both DateField and TimeField blur events

        // revert focus to previous field if clicked in between
        if(this.wrapClick) {
            f.focus();
            this.wrapClick = false;
        }

        // update underlying value
        if(f === this.df) {
            this.updateDate();
        }
        else {
            this.updateTime();
        }
        this.updateHidden();

        // fire events later
        (function() {
            if(!this.df.hasFocus && !this.tf.hasFocus) {
                var v = this.getValue();
                if(String(v) !== String(this.startValue)) {
                    this.fireEvent("change", this, v, this.startValue);
                }
                this.hasFocus = false;
                this.fireEvent('blur', this);
            }
        }).defer(100, this);

    } // eo function onBlur
    // }}}
    // {{{
    /**
     * @private Handles focus event
     */
    ,onFocus:function() {
        if(!this.hasFocus){
            this.hasFocus = true;
            this.startValue = this.getValue();
            this.fireEvent("focus", this);
        }
    }
    // }}}
    // {{{
    /**
     * @private Just to prevent blur event when clicked in the middle of fields
     */
    ,onMouseDown:function(e) {
        if(!this.disabled) {
            this.wrapClick = 'td' === e.target.nodeName.toLowerCase();
        }
    }
    // }}}
    // {{{
    /**
     * @private
     * Handles Tab and Shift-Tab events
     */
    ,onSpecialKey:function(t, e) {
        var key = e.getKey();
        if(key === e.TAB) {
            if(t === this.df && !e.shiftKey) {
                e.stopEvent();
                this.tf.focus();
            }
            if(t === this.tf && e.shiftKey) {
                e.stopEvent();
                this.df.focus();
            }
        }
        // otherwise it misbehaves in editor grid
        if(key === e.ENTER) {
            this.updateValue();
        }

    } // eo function onSpecialKey
    // }}}
    // {{{
    /**
     * @private Sets the value of DateField
     */
    ,setDate:function(date) {
        this.df.setValue(date);
    } // eo function setDate
    // }}}
    // {{{
    /**
     * @private Sets the value of TimeField
     */
    ,setTime:function(date) {
        this.tf.setValue(date);
    } // eo function setTime
    // }}}
    // {{{
    /**
     * @private
     * Sets correct sizes of underlying DateField and TimeField
     * With workarounds for IE bugs
     */
    ,setSize:function(w, h) {
        if(!w) {
            return;
        }
        if('below' === this.timePosition) {
            this.df.setSize(w, h);
            this.tf.setSize(w, h);
            if(Ext.isIE) {
                this.df.el.up('td').setWidth(w);
                this.tf.el.up('td').setWidth(w);
            }
        }
        else {
            this.df.setSize(w - this.timeWidth - 4, h);
            this.tf.setSize(this.timeWidth, h);

            if(Ext.isIE) {
                this.df.el.up('td').setWidth(w - this.timeWidth - 4);
                this.tf.el.up('td').setWidth(this.timeWidth);
            }
        }
    } // eo function setSize
    // }}}
    // {{{
    /**
     * @param {Mixed} val Value to set
     * Sets the value of this field
     */
    ,setValue:function(val) {
        if(!val && true === this.emptyToNow) {
            this.setValue(new Date());
            return;
        }
        else if(!val) {
            this.setDate('');
            this.setTime('');
            this.updateValue();
            return;
        }
        if ('number' === typeof val) {
          val = new Date(val);
        }
        else if('string' === typeof val && this.hiddenFormat) {
            val = Date.parseDate(val, this.hiddenFormat)
        }
        val = val ? val : new Date(1970, 0 ,1, 0, 0, 0);
        var da, time;
        if(val instanceof Date) {
            this.setDate(val);
            this.setTime(val);
            this.dateValue = new Date(val);
        }
        else {
            da = val.split(this.dtSeparator);
            this.setDate(da[0]);
            if(da[1]) {
                if(da[2]) {
                    // add am/pm part back to time
                    da[1] += da[2];
                }
                this.setTime(da[1]);
            }
        }
        this.updateValue();
    } // eo function setValue
    // }}}
    // {{{
    /**
     * Hide or show this component by boolean
     * @return {Ext.Component} this
     */
    ,setVisible: function(visible){
        if(visible) {
            this.df.show();
            this.tf.show();
        }else{
            this.df.hide();
            this.tf.hide();
        }
        return this;
    } // eo function setVisible
    // }}}
    //{{{
    ,show:function() {
        return this.setVisible(true);
    } // eo function show
    //}}}
    //{{{
    ,hide:function() {
        return this.setVisible(false);
    } // eo function hide
    //}}}
    // {{{
    /**
     * @private Updates the date part
     */
    ,updateDate:function() {

        var d = this.df.getValue();
        if(d) {
            if(!(this.dateValue instanceof Date)) {
                this.initDateValue();
                if(!this.tf.getValue()) {
                    this.setTime(this.dateValue);
                }
            }
            this.dateValue.setMonth(0); // because of leap years
            this.dateValue.setFullYear(d.getFullYear());
            this.dateValue.setMonth(d.getMonth(), d.getDate());
//            this.dateValue.setDate(d.getDate());
        }
        else {
            this.dateValue = '';
            this.setTime('');
        }
    } // eo function updateDate
    // }}}
    // {{{
    /**
     * @private
     * Updates the time part
     */
    ,updateTime:function() {
        var t = this.tf.getValue();
        if(t && !(t instanceof Date)) {
            t = Date.parseDate(t, this.tf.format);
        }
        if(t && !this.df.getValue()) {
            this.initDateValue();
            this.setDate(this.dateValue);
        }
        if(this.dateValue instanceof Date) {
            if(t) {
                this.dateValue.setHours(t.getHours());
                this.dateValue.setMinutes(t.getMinutes());
                this.dateValue.setSeconds(t.getSeconds());
            }
            else {
                this.dateValue.setHours(0);
                this.dateValue.setMinutes(0);
                this.dateValue.setSeconds(0);
            }
        }
    } // eo function updateTime
    // }}}
    // {{{
    /**
     * @private Updates the underlying hidden field value
     */
    ,updateHidden:function() {
        if(this.isRendered) {
            var value = this.dateValue instanceof Date ? this.dateValue.format(this.hiddenFormat) : '';
            this.el.dom.value = value;
        }
    }
    // }}}
    // {{{
    /**
     * @private Updates all of Date, Time and Hidden
     */
    ,updateValue:function() {

        this.updateDate();
        this.updateTime();
        this.updateHidden();

        return;
    } // eo function updateValue
    // }}}
    // {{{
    /**
     * @return {Boolean} true = valid, false = invalid
     * calls validate methods of DateField and TimeField
     */
    ,validate:function() {
        return this.df.validate() && this.tf.validate();
    } // eo function validate
    // }}}
    // {{{
    /**
     * Returns renderer suitable to render this field
     * @param {Object} Column model config
     */
    ,renderer: function(field) {
        var format = field.editor.dateFormat || Ext.ux.form.DateTime.prototype.dateFormat;
        format += ' ' + (field.editor.timeFormat || Ext.ux.form.DateTime.prototype.timeFormat);
        var renderer = function(val) {
            var retval = Ext.util.Format.date(val, format);
            return retval;
        };
        return renderer;
    } // eo function renderer
    // }}}

}); // eo extend

// register xtype
Ext.reg('xdatetime', Ext.ux.form.DateTime);

// eof
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

// Temporary fix for Ext 3.1 resize problem:
Ext.override(Ext.Panel, {

   // private
    onResize : function(w, h, rw, rh){
        if(Ext.isDefined(w) || Ext.isDefined(h)){
            if(!this.collapsed){
                // First, set the the Panel's body width.
                // If we have auto-widthed it, get the resulting full offset width so we can size the Toolbars to match
                // The Toolbars must not buffer this resize operation because we need to know their heights.

                if(Ext.isNumber(w)){
                    this.body.setWidth(w = this.adjustBodyWidth(w - this.getFrameWidth()));
                } else if (w == 'auto') {
                    w = this.body.setWidth('auto').dom.offsetWidth;
                } else {
                    w = this.body.dom.offsetWidth;
                }

                if(this.tbar){
                    this.tbar.setWidth(w);
                    if(this.topToolbar){
                        this.topToolbar.setSize(w);
                    }
                }
                if(this.bbar){
                    this.bbar.setWidth(w);
                    if(this.bottomToolbar){
                        this.bottomToolbar.setSize(w);
                        // The bbar does not move on resize without this.
                        if (Ext.isIE) {
                            this.bbar.setStyle('position', 'static');
                            this.bbar.setStyle('position', '');
                        }
                    }
                }
                if(this.footer){
                    this.footer.setWidth(w);
                    if(this.fbar){
                        this.fbar.setSize(Ext.isIE ? (w - this.footer.getFrameWidth('lr')) : 'auto');
                    }
                }

                // At this point, the Toolbars must be layed out for getFrameHeight to find a result.
                if(Ext.isNumber(h)){
                    h = Math.max(0, this.adjustBodyHeight(h - this.getFrameHeight()));
                    this.body.setHeight(h);
                }else if(h == 'auto'){
                    this.body.setHeight(h);
                }

                if(this.disabled && this.el._mask){
                    this.el._mask.setSize(this.el.dom.clientWidth, this.el.getHeight());
                }
            }else{
                this.queuedBodySize = {width: w, height: h};
                if(!this.queuedExpand && this.allowQueuedExpand !== false){
                    this.queuedExpand = true;
                    this.on('expand', function(){
                        delete this.queuedExpand;
                        this.onResize(this.queuedBodySize.width, this.queuedBodySize.height);
                    }, this, {single:true});
                }
            }
            this.onBodyResize(w, h);
        }
        this.syncShadow();
        Ext.Panel.superclass.onResize.call(this, w, h, rw, rh);
    }
});

Ext.ns('Ext.ux.form');
Ext.ux.form.TriCheckbox = Ext.extend(Ext.form.Checkbox, {
  checked: null,
  valueList: [null, false, true],
  stateClassList: ['x-checkbox-undef', null, 'x-checkbox-checked'],
  overClass: 'x-form-check-over',
  clickClass: 'x-form-check-down',
  triState: true,
  defaultAutoCreate: {tag: 'input', type: 'hidden', autocomplete: 'off'},
  initComponent: function() {
    this.value = this.checked;
    Ext.ux.form.TriCheckbox.superclass.initComponent.apply(this, arguments);
    // make a copy before modifying valueList and stateClassList arrays
    this.vList = this.valueList.slice(0);
    this.cList = this.stateClassList.slice(0);
    if(this.triState !== true) {
      // consider 'undefined' value and its class go first in arrays
      this.vList.shift();
      this.cList.shift();
    }
    if(this.overCls !== undefined) {
      this.overClass = this.overCls;
      delete this.overCls;
    }
    this.value = this.normalizeValue(this.value);
  },
  onRender : function(ct, position){
    Ext.form.Checkbox.superclass.onRender.call(this, ct, position);

    this.innerWrap = this.el.wrap({tag: 'span', cls: 'x-form-check-innerwrap'});
    this.wrap = this.innerWrap.wrap({cls: 'x-form-check-wrap'});

    this.currCls = this.getCls(this.value);
    this.wrap.addClass(this.currCls);
    if(this.clickClass && !this.disabled && !this.readOnly)
      this.innerWrap.addClassOnClick(this.clickClass);
    if(this.overClass && !this.disabled && !this.readOnly)
      this.innerWrap.addClassOnOver(this.overClass);

    this.imageEl = this.innerWrap.createChild({
      tag: 'img',
      src: Ext.BLANK_IMAGE_URL,
      cls: 'x-form-tscheckbox'
    }, this.el);
    if(this.fieldClass) this.imageEl.addClass(this.fieldClass);

    if(this.boxLabel){
      this.innerWrap.createChild({
        tag: 'label',
        htmlFor: this.el.id,
        cls: 'x-form-cb-label',
        html: this.boxLabel
      });
    }

    // Need to repaint for IE, otherwise positioning is broken
    if(Ext.isIE){
      this.wrap.repaint();
    }
    this.resizeEl = this.positionEl = this.wrap;
  },
  onResize : function(){
    Ext.form.Checkbox.superclass.onResize.apply(this, arguments);
    if(!this.boxLabel && !this.fieldLabel && this.imageEl){
      this.imageEl.alignTo(this.wrap, 'c-c');
    }
  },
  initEvents : function(){
    Ext.form.Checkbox.superclass.initEvents.call(this);
    this.mon(this.innerWrap, {
      scope: this,
      click: this.onClick
    });
  },
  onClick : function(){
    if (!this.disabled && !this.readOnly) {
      this.setValue(this.vList[(this.vList.indexOf(this.value) + 1) % this.vList.length]);
    }
  },
  getValue : function(){
    return this.value;
  },
  setValue : function(v){
    var value = this.value;
    this.value = this.normalizeValue(v);
    if(this.rendered) this.el.dom.value = this.value;

    if(value !== this.value){
      this.updateView();
      this.fireEvent('check', this, this.value);
      if(this.handler) this.handler.call(this.scope || this, this, this.value);
    }
    return this;
  },
  normalizeValue: function(v) {
    return (v === null || v === undefined) && this.triState ? null :
      (v === true || (['true', 'yes', 'on', '1']).indexOf(String(v).toLowerCase()) != -1);
  },
  getCls: function(v) {
    var idx = this.vList.indexOf(this.value);
    return idx > -1 ? this.cList[idx] : undefined;
  },
  updateView: function() {
    var cls = this.getCls(this.value);
    if (!this.wrap || cls === undefined) return;

    this.wrap.replaceClass(this.currCls, cls);
    this.currCls = cls;
  }
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