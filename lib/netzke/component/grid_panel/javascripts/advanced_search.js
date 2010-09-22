Ext.override(Netzke.pre.GridPanel, {
  onSearch: function(){
      delete this.searchWindow;
      this.searchWindow = new Ext.Window({
        title:'Advanced search',
        layout:'fit',
        modal: true,
        width: 400,
        height: Ext.lib.Dom.getViewHeight() *0.9,
        closeAction:'close',
        buttons:[{
          text: 'OK',
          handler: function(){
            this.ownerCt.ownerCt.closePositively();
          }
        },{
          text:'Cancel',
          handler:function(){
            this.ownerCt.ownerCt.closeNegatively();
          }
        }],
        closePositively : function(){
          this.conditions = this.getComponent().getForm().getValues();
          this.closeRes = 'OK'; 
          this.close();
        },
        closeNegatively: function(){
          this.closeRes = 'cancel'; 
          this.close();
        }
      });

      this.searchWindow.on('close', function(){
        if (this.searchWindow.closeRes == 'OK'){
          var searchConditions = this.searchWindow.conditions;
          var filtered = false;
          // check if there's any search condition set
          for (var k in searchConditions) {
            if (searchConditions[k].length > 0) {
              filtered = true;
              break;
            }
          }
          this.actions.search.setText(filtered ? "Search *" : "Search");
          this.getStore().baseParams = {extra_conditions: Ext.encode(this.searchWindow.conditions)};
          this.getStore().load();
        }
      }, this);

      this.searchWindow.on('add', function(container, searchPanel){
        searchPanel.on('apply', function(component){
          this.searchWindow.closePositively();
          return false; // stop the event
        }, this);
      }, this);

      this.searchWindow.show(null, function(){
        this.searchWindow.closeRes = 'cancel';
        if (!this.searchWindow.getComponent()){
          this.loadComponent({id:"searchPanel", container:this.searchWindow.id});
        }
      }, this);

    }
});