Ext.ns("Netzke.classes.Basepack.SearchPanel");

Netzke.classes.Basepack.SearchPanel.ConditionField = Ext.extend(Ext.form.CompositeField, {
  hideLabel: true,

  // Config refinements for the value field
  valueFieldConfigs: {
    string: {
      xtype : 'textfield'
    },
    datetime: {
      xtype : 'datefield'
    },
    integer: {
      xtype: 'numberfield'
    }
  },

  initComponent: function(){
    // if (!this.attrType) this.attrType = 'string';
    var items = [
      // attribute combo
      {
        xtype     : 'combo',
        store: this.ownerCt.attrs,
        allowBlank: true,
        name: this.attr + '_attr',
        ref: 'attrCombo',
        emptyText: 'Attribute',
        triggerAction: 'all',
        value: this.attr ? this.attr.underscore() : "",
        listeners: {
          select: this.onAttributeChange,
          scope: this
        }
      }
    ];

    if (this.attr) {

      var operators = this.ownerCt.attributeOperatorsMap[this.attrType] || [[]];

      if (this.attrType === 'boolean') {
        items.push({
          xtype     : 'checkbox',
          width: 100,
          name: this.attr + '_value',
          ref: 'valueField',
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
            width: 100,
            xtype     : 'combo',
            fieldLabel: 'Operator',
            store: operators,
            name: this.attr + '_operator',
            value: this.operator || operators[0][0],
            autoSelect: true,
            triggerAction: 'all',
            emptyText: "Operator",
            ref: "operatorCombo"
          }
        );

        // value field
        items.push(Ext.apply(
          {
            xtype     : 'textfield',
            emptyText: "Value",
            flex: 1,
            name: this.attr + '_value',
            ref: 'valueField',
            value: this.value,
            ref: "valueField"
          },
          this.valueFieldConfigs[this.attrType] // refining the config dependent on the attr type
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

    // Why on Earth is this not working? Netzke.classes.Basepack.SearchPanel.ConditionField undefined???
    // Netzke.classes.Basepack.SearchPanel.ConditionField.superclass.initComponent.call(this);
    Ext.form.CompositeField.prototype.initComponent.call(this); // workaround

    this.addEvents('configured'); // user selects the attribute from the attribute combo
  },

  isConfigured: function() {
    return !!this.attrCombo.getValue();
  },

  removeSelf: function(){
    var ownerCt = this.ownerCt;
    this.destroy();
    ownerCt.fireEvent('fieldsnumberchange');
  },

  onAttributeChange: function(e){
    this.fireEvent('configured');
    this.changeAttribute(e.value.camelize(true));
  },

  // Dynamically replace self with a field with different attrType
  changeAttribute: function(attr){
    var attrType = this.ownerCt.attrsHash[attr];
    var idx = this.ownerCt.items.indexOf(this);
    var owner = this.ownerCt;
    var newSelf = Ext.create(Ext.apply(this.initialConfig, {name: attr, attrType: attrType, attr: attr.underscore(), ownerCt: this.ownerCt, operator: null}));
    owner.remove(this);
    owner.insert(idx, newSelf);
    owner.doLayout();
  },

  // Returns true if it should be in the query
  valueIsSet: function(){
    return !!(this.attrCombo.getValue() && (this.attrType === 'boolean' || this.operatorCombo.getValue()) && !Ext.isEmpty(this.valueField.getValue()));
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

Ext.reg('netzkebasepacknewsearchpanelconditionfield', Netzke.classes.Basepack.SearchPanel.ConditionField);
