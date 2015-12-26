{
  layout: 'fit',

  initComponent: function(){
    this.callParent();

    // set the move and resize events after window is shown, so that they don't fire at initial rendering
    if (this.persistence) {
      this.on("show", function(){
        this.on("move", this.netzkeOnMoveResize, this);
        this.on("resize", this.netzkeOnMoveResize, this);
        this.on("maximize", Ext.Function.pass(this.netzkeOnMaximize, [true]), this);
        this.on("restore", Ext.Function.pass(this.netzkeOnMaximize, [false]), this);
      }, this);
    }
  },

  netzkeOnMoveResize: function(){
    var x = this.getPosition()[0], y = this.getPosition()[1], w = this.getSize().width, h = this.getSize().height;
    this.server.setSizeAndPosition({x: x, y: y, width: w, height: h}); // API call
  },

  netzkeOnMaximize: function(maximized) {
    this.server.setMaximized(maximized);
  }
}
