{
  rememberSelection: function(selModel, selectedRecords) {
    if (!this.rendered || Ext.isEmpty(this.el)) {
      return;
    }

    this.selectedRecords = this.getSelectionModel().getSelection();
  },
  refreshSelection: function() {
    if (!this.selectedRecords.length || 0 >= this.selectedRecords.length) {
      return;
    }

    var newRecordsToSelect = [];
    for (var i = 0; i < this.selectedRecords.length; i++) {
      record = this.getStore().getById(this.selectedRecords[i].getId());
      if (!Ext.isEmpty(record)) {
        newRecordsToSelect.push(record);
      }
    }

    this.getSelectionModel().select(newRecordsToSelect);
  }
}

