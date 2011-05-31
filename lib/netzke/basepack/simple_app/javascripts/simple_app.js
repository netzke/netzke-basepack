{
  initComponent: function(){
    this.callParent();

    var statusBar = this.query('#main-statusbar')[0];

    Ext.History.on('change', this.processHistory, this);

    // Setting the "busy" indicator for Ajax requests
    Ext.Ajax.on('beforerequest',    function(){ statusBar.showBusy(); });
    Ext.Ajax.on('requestcomplete',  function(){ statusBar.hideBusy(); });
    Ext.Ajax.on('requestexception', function(){ statusBar.hideBusy(); });

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
      this.query('#main-panel')[0].removeChild();
    }
  },

  instantiateComponent: function(config){
    this.query('#main-panel')[0].instantiateChild(config);
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
