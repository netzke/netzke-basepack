{
  layout: 'fit',

  initComponent: function(){
    this.callParent();

    // set the move and resize events after window is shown, so that they don't fire at initial rendering
    if (this.persistence) {
      this.on("show", function(){
        this.on("move", this.handleMoveResize, this);
        this.on("resize", this.handleMoveResize, this);
        this.on("maximize", Ext.Function.pass(this.handleMaximize, [true]), this);
        this.on("restore", Ext.Function.pass(this.handleMaximize, [false]), this);
      }, this);
    }
  },

  handleMoveResize: function(){
    var x = this.getPosition()[0], y = this.getPosition()[1], w = this.getSize().width, h = this.getSize().height;
    this.server.setSizeAndPosition({x: x, y: y, width: w, height: h}); // API call
  },

  handleMaximize: function(maximized) {
    this.server.setMaximized(maximized);
  }
}
