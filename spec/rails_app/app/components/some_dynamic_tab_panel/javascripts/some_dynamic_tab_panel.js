{
  onLoadInCurrentTab: function(){
    this.netzkeLoadComponentByClass('Grid::Crud', {clientConfig: {counter: this.getCounter()}});
  },

  onLoadInNewTab: function(){
    this.netzkeLoadComponentByClass('Netzke::Core::Panel', {newTab: true, clientConfig: {counter: this.getCounter()}});
  },

  // private
  getCounter: function(){
    this.counter = this.counter || 0;
    this.counter += 1;
    return this.counter;
  }
}
