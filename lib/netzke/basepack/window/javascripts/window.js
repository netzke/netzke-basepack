{
  layout: 'fit',

  initComponent: function(){
    this.callParent();

    // set the move and resize events after window is shown, so that they don't fire at initial rendering
    this.on("show", function(){
      this.on("move", this.onMoveResize, this);
      this.on("resize", this.onMoveResize, this);
    }, this);
  },

  onMoveResize: function(){
    var x = this.getPosition()[0], y = this.getPosition()[1], w = this.getSize().width, h = this.getSize().height;
    this.setSizeAndPosition({x:x, y:y, w:w, h:h}); // API call
  }
}