{
  netzkeOnShowFirst: function(){
    var one = this.getStore().getAt(0).get('meta_attribute');
    this.setTitle(one);
  },

  netzkeOnShowSecond: function(){
    var one = this.getStore().getAt(1).get('meta_attribute');
    this.setTitle(one);
  }
}
