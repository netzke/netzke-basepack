{
  onLoadInCurrentTab: function(){
    this.nzLoadComponentByClass('Grid::Crud', {serverConfig: {counter: this.getCounter()}});
  },

  onLoadInNewTab: function(){
    this.nzLoadComponentByClass('Netzke::Core::Panel', { newTab: true, serverConfig: {counter: this.getCounter()} });
  },

  // private
  getCounter: function(){
    this.counter = this.counter || 0;
    this.counter += 1;
    return this.counter;
  }
}
