Ext.ns("Netzke.classes.Basepack.NewSearchPanel");
Netzke.classes.Basepack.NewSearchPanel.ConditionField = Ext.extend(Ext.form.CompositeField, {
  hideLabel: true,

  valueFieldConfigs: {
    string: {
      xtype     : 'textfield'
    },
    datetime: {
      xtype : 'datefield'
    },
    integer: {
      xtype: 'numberfield'
    },
    "boolean": {
      hidden: true
    }
  },

  initComponent: function(){
    if (!this.attrType) this.attrType = 'string';

    var items = [
        {
            xtype     : 'combo',
            store: this.ownerCt.attrs,
            allowBlank: true,
            name: 'attr',
            emptyText: 'Attribute',
            triggerAction: 'all',
            value: this.attr ? this.attr.underscore() : "",
            listeners: {
              select: this.onAttributeChange,
              scope: this
            }
        }
    ];

    var operators = this.ownerCt.attributeOperatorsMap[this.attrType] || this.ownerCt.attributeOperatorsMap['string'];

    // console.info("operatorValue: ", operatorValue);
    // if (this.attrType == 'boolean') {
    //   items.push({
    //     xtype: 'checkbox',
    //     checked: this.value == true
    //   });
    // } else {
      items.push(
        {
            xtype     : 'combo',
            fieldLabel: 'Operator',
            store: operators,
            name: 'operator',
            value: this.operator,
            autoSelect: true,
            triggerAction: 'all',
            emptyText: "Operator",
            ref: "operatorCombo",
            // hidden: true
        }
      );
    // }

    items.push(Ext.apply({
      xtype     : 'textfield',
      emptyText: "Value",
      name: 'value',
      value: this.value,
      ref: "valueField"
    }, this.valueFieldConfigs[this.attrType]));

    items.push({
      xtype: 'button',
      cls: 'x-btn-icon',
      icon: "/images/icons/cross_small.png",
      handler: this.onRemoveField,
      scope: this
    });

    this.items = items;

    Ext.form.CompositeField.prototype.initComponent.call(this);

    // Why on Earth is this not working? Netzke.classes.Basepack.NewSearchPanel.ConditionField undefined???
    // Netzke.classes.Basepack.NewSearchPanel.ConditionField.superclass.initComponent.call(this);

  },

  onRemoveField: function(){
    this.destroy();
  },

  onAttributeChange: function(e){
    // var attrType = this.ownerCt.attrsHash[e.value.camelize(true)];
    this.changeAttribute(e.value.camelize(true));

    // var operators = this.ownerCt.attributeOperatorsMap[this.attrType] || this.ownerCt.attributeOperatorsMap['string'];
    // this.operatorCombo.getStore().loadData(operators);
    // this.operatorCombo.setValue(this.operatorCombo.getStore().getAt(0).data['field2']);
    // this.changeType(attrType);
    // this.setValueField();
  },

  changeAttribute: function(attr){
    var attrType = this.ownerCt.attrsHash[attr];
    var idx = this.ownerCt.items.indexOf(this);
    var owner = this.ownerCt
    owner.remove(this);
    owner.insert(idx, Ext.apply(this.initialConfig, {attrType: attrType, attr: attr}));
    owner.doLayout();
    this.destroy();
  }

  // setValueField: function(){
  //   this.valueField.setVisible(this.attrType != 'boolean');
  // }

});

Ext.reg('netzkebasepacknewsearchpanelconditionfield', Netzke.classes.Basepack.NewSearchPanel.ConditionField);
