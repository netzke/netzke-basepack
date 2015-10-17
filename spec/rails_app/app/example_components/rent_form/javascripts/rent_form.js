{
  initComponent: function(){
    this.callParent();

    var authorCombo = this.getComponent('authorCombo');
    var bookCombo = this.getComponent('bookCombo');

    var handleAuthorChange = function(cb, author){
      bookCombo.getStore().clearFilter();
      bookCombo.clearValue();
      bookCombo.getStore().filterBy(function(book, id){
        return book.get('field3') == author.get('field1');
      });
    }

    authorCombo.addListener('select', handleAuthorChange, this);
  }
}
