{
  layout: 'fit',

  initComponent: function(){
    this.callParent();

    // set the move and resize events after window is shown, so that they don't fire at initial rendering
    if (this.persistence) {
      this.on("show", function(){
        this.on("move", this.onMoveResize, this);
        this.on("resize", this.onMoveResize, this);
        this.on("maximize", Ext.Function.pass(this.onMaximize, [true]), this);
        this.on("restore", Ext.Function.pass(this.onMaximize, [false]), this);
      }, this);
    }
  },

  onMoveResize: function(){
    var x = this.getPosition()[0], y = this.getPosition()[1], w = this.getSize().width, h = this.getSize().height;
    this.server.setSizeAndPosition({x: x, y: y, width: w, height: h}); // API call
  },

  onMaximize: function(maximized) {
    this.server.setMaximized(maximized);
  }
}
