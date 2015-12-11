{
  onShowFirst: function(){
    var one = this.getStore().getAt(0).get('meta_attribute');
    this.setTitle(one);
  },

  onShowSecond: function(){
    var one = this.getStore().getAt(1).get('meta_attribute');
    this.setTitle(one);
  }
}
