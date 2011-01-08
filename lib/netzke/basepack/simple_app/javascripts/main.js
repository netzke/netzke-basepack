{
  initComponent: function(){
    Netzke.classes.Basepack.SimpleApp.superclass.initComponent.call(this);

    Ext.History.on('change', this.processHistory, this);

    // Setting the "busy" indicator for Ajax requests
    Ext.Ajax.on('beforerequest', function(){this.findById('main-statusbar').showBusy()}, this);
    Ext.Ajax.on('requestcomplete', function(){this.findById('main-statusbar').hideBusy()}, this);
    Ext.Ajax.on('requestexception', function(){this.findById('main-statusbar').hideBusy()}, this);

    // Initialize history
    Ext.History.init();
  },

  afterRender: function(){
    Netzke.classes.Basepack.SimpleApp.superclass.afterRender.call(this);

    // If we are given a token, load the corresponding component, otherwise load the last loaded component
    var currentToken = Ext.History.getToken();
    if (currentToken != "") {
      this.processHistory(currentToken);
    } else {
      var lastLoaded = this.initialConfig.componentToLoad; // passed from the server
      if (lastLoaded) Ext.History.add(lastLoaded);
    }
  },

  processHistory: function(token){
    if (token){
      this.loadComponent({name:token, container:'main-panel'});
    } else {
      Ext.getCmp('main-panel').removeChild();
    }
  },

  instantiateComponent: function(config){
    this.findById('main-panel').instantiateChild(config);
  },

  appLoadComponent: function(name){
    Ext.History.add(name);
  },

  loadComponentByAction: function(action){
    var componentName = action.component || action.name;
    if (componentName) this.appLoadComponent(componentName);
  },

  onToggleConfigMode: function(params){
    this.toggleConfigMode();
  }
}
