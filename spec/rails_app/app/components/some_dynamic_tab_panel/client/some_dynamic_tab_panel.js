{
  netzkeOnLoadInCurrentTab: function(){
    this.netzkeLoadComponentByClass('Grid::Crud', {serverConfig: {counter: this.getCounter()}});
  },

  netzkeOnLoadInNewTab: function(){
    this.netzkeLoadComponentByClass('Netzke::Core::Panel', { newTab: true, serverConfig: {counter: this.getCounter()} });
  },

  // private
  getCounter: function(){
    this.counter = this.counter || 0;
    this.counter += 1;
    return this.counter;
  }
}
