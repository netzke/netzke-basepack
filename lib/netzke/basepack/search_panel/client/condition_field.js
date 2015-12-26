Ext.define('Netzke.Basepack.SearchPanel.ConditionField', {
  extend:     'Ext.form.FieldContainer',
  alias:      'widget.netzkebasepacksearchpanelconditionfield',

  hideLabel:  true,
  layout:     'hbox',

  // Config refinements for the value field
  valueFieldConfigs: {
    string: {
      xtype : 'textfield'
    },
    datetime: {
      xtype : 'datefield'
    },
    date: {
      xtype : 'datefield'
    },
    integer: {
      xtype: 'numberfield'
    }
  },

  initComponent: function(){
    if (!this.type || this.assoc) this.type = 'string';

    this.typeHash = {};

    var storeData = Ext.Array.map(this.ownerCt.attrs, function(attr) {
      this.typeHash[attr.name] = attr.type;
      return [attr.name, attr.text];
    }, this);

    var items = [
      // attribute combo
      {
        xtype     : 'combo',
        store: storeData,
        allowBlank: true,
        // store: [],
        name: this.attr + '_attr',
        itemId: 'attrCombo',
        emptyText: 'Attribute',
        triggerAction: 'all',
        value: this.attr ? this.attr.underscore() : "",
        listeners: {
          select: this.netzkeOnAttributeChange,
          scope: this
        }
      }
    ];

    if (this.attr) {

      var operators = this.ownerCt.attributeOperatorsMap[this.type] || [[]];

      if (this.type === 'boolean') {
        items.push({
          xtype     : 'tricheckbox',
          width: 100,
          name: this.attr + '_value',
          itemId: 'valueField',
          checked: this.value
        });

        items.push({
          flex: 1,
          xtype: 'displayfield'
        });
      } else {
        // operator combo
        items.push(
          {
            width:      100,
            xtype:      'combo',
            fieldLabel: 'Operator',
            hideLabel:  true,
            store:      operators,
            name:       this.attr + '_operator',
            value:      this.operator || operators[0][0],
            autoSelect: true,
            triggerAction: 'all',
            emptyText:  "Operator",
            itemId:     "operatorCombo"
          }
        );

        // value field
        items.push(Ext.apply(
          {
            xtype: 'textfield',
            emptyText: "Value",
            flex: 1,
            name: this.attr + '_value',
            value: this.value,
            itemId: "valueField"
          },
          this.valueFieldConfigs[this.type] // refining the config dependent on the attr type
        ));
      }

      // delete button
      items.push({
        xtype: 'button',
        cls: 'x-btn-icon',
        icon: Netzke.RelativeUrlRoot + "/images/icons/cross.png",
        handler: this.removeSelf,
        scope: this
      });
    }

    this.items = items;

    this.callParent();

    this.attrCombo = this.getComponent('attrCombo');
    this.operatorCombo = this.getComponent('operatorCombo');
    this.valueField = this.getComponent('valueField');
  },

  isConfigured: function() {
    return !!this.attrCombo.getValue();
  },

  removeSelf: function(){
    var ownerCt = this.ownerCt;
    this.destroy();
    ownerCt.fireEvent('fieldsnumberchange');
  },

  netzkeOnAttributeChange: function(e){
    this.fireEvent('configured');
    this.changeAttribute(e.value);
  },

  // Dynamically replace self with a field with different type
  changeAttribute: function(attr){
    var type = this.typeHash[attr];
    var idx = this.ownerCt.items.indexOf(this);
    var owner = this.ownerCt;
    var newSelf = Ext.createByAlias('widget.netzkebasepacksearchpanelconditionfield', Ext.apply(this.initialConfig, {name: attr, type: type, attr: attr.underscore(), ownerCt: this.ownerCt, operator: null}));
    owner.insert(idx, newSelf);
    setTimeout(function() { this.destroy(); }.bind(this), 1); // this gives time for pending events to get handled without errors
  },

  // Returns true if it should be in the query
  valueIsSet: function(){
    return !!(this.attrCombo.getValue() && (this.type === 'boolean' || this.operatorCombo.getValue()) && !Ext.isEmpty(this.valueField.getValue()));
  },

  // Returns the query object
  buildValue: function(){
    var res = {attr: this.attrCombo.getValue(), value: this.valueField.getValue()};
    if (this.attrType !== 'boolean') {
      res.operator = this.operatorCombo.getValue();
    }
    return res;
  },

  clearValue: function() {
    this.valueField.reset();
  }

});
