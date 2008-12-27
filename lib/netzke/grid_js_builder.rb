module Netzke::GridJsBuilder
  def js_base_class 
    'Ext.grid.EditorGridPanel'
  end

  def js_bbar
    <<-JS.l
    (config.rowsPerPage) ? new Ext.PagingToolbar({
      pageSize:config.rowsPerPage, 
      items:config.actions, 
      store:ds, 
      emptyMsg:'Empty'}) : config.actions
    JS
  end

  def js_default_config
    super.merge({
      :store => "ds".l,
      :cm => "cm".l,
      :sel_model => "new Ext.grid.RowSelectionModel()".l,
      :auto_scroll => true,
      :click_to_edit => 2,
      :track_mouse_over => true,
      # :bbar => "config.actions".l,
      :bbar => js_bbar,
      
      #custom configs
      :auto_load_data => true
    })
  end
  
  def js_before_constructor
    <<-JS
    this.recordConfig = [];

  	if (!config.columns) {
  	  this.feedback('No columns defined for grid '+config.id);
	  }
    
    Ext.each(config.columns, function(column){this.recordConfig.push({name:column.name})}, this);
    this.Row = Ext.data.Record.create(this.recordConfig);
    var ds = new Ext.data.Store({
        proxy: this.proxy = new Ext.data.HttpProxy({url:config.interface.getData}),
        reader: new Ext.data.ArrayReader({root: "data", totalProperty: "total", successProperty: "succes", id:0}, this.Row),
        remoteSort: true
    });

    this.cmConfig = [];
    Ext.each(config.columns, function(c){
      var editor = c.readOnly ? null : Ext.netzke.editors[c.showsAs](c, config);

      this.cmConfig.push({
        header: c.label || c.name,
        dataIndex: c.name,
        hidden: c.hidden,
        width: c.width,
        editor: editor,
        sortable: true
      })
    }, this);

    var cm = new Ext.grid.ColumnModel(this.cmConfig);
    
    this.addEvents("refresh");
  	
    JS
  end
  
  def js_extend_properties
    {
      :on_widget_load => <<-JS.l,
        function(){
          if (this.initialConfig.autoLoadData) {
            this.loadWithFeedback({start:0, limit: this.initialConfig.rowsPerPage})
          }
        }
      JS
    
      :load_with_feedback => <<-JS.l,
        function(params){
          if (!params) params = {};
      	  var exceptionHandler = function(proxy, options, response, error){
            if (response.status == 200 && (responseObject = Ext.decode(response.responseText)) && responseObject.flash){
              this.feedback(responseObject.flash)
            } else {
              if (error){
                this.feedback(error.message);
              } else {
                this.feedback(response.statusText)
              }  
            }
          }.createDelegate(this);
      	  this.store.proxy.on('loadexception', exceptionHandler);
      		this.store.load({callback:function(r, options, success){
      			this.store.proxy.un('loadexception', exceptionHandler);
      		}, params: params, scope:this});
      	}
      JS
      
      :add => <<-JS.l,
        function(){
          var rowConfig = {};
          Ext.each(this.initialConfig.columns, function(c){
            rowConfig[c.name] = c.defaultValue || ''; // FIXME: if the user is happy with all the defaults, the record won't be 'dirty'
          }, this);
          
          var r = new this.Row(rowConfig); // TODO: add default values
          r.set('id', -r.id); // to distinguish new records by negative values
          this.stopEditing();
      		this.store.add(r);
      		this.store.newRecords = this.store.newRecords || []
      		this.store.newRecords.push(r);
          // console.info(this.store.newRecords);
          this.tryStartEditing(this.store.indexOf(r));
      	}
      JS
    
      :edit => <<-JS.l,
        function(){
          var row = this.getSelectionModel().getSelected();
          if (row){
            this.tryStartEditing(this.store.indexOf(row))
          }
        }
      JS
    
      # try editing the first editable (not hidden, not read-only) sell
      :try_start_editing => <<-JS.l,
      	function(row){
      	  if (row == null) return;
      		var editableColumns = this.getColumnModel().getColumnsBy(function(columnConfig, index){
      			return !columnConfig.hidden && !!columnConfig.editor;
      		});
      		// console.info(editableColumns);
      		var firstEditableColumn = editableColumns[0];
      		if (firstEditableColumn){
      			this.startEditing(row, firstEditableColumn.id);
      		}
      	}
      JS

      :delete => <<-JS.l,
        function() {
          if (this.getSelectionModel().hasSelection()){
            Ext.Msg.confirm('Confirm', 'Are you sure?', function(btn){
              if (btn == 'yes') {
                var records = []
                this.getSelectionModel().each(function(r){
          		    records.push(r.get('id'));
                }, this);
        		    Ext.Ajax.request({
            			url: this.initialConfig.interface.deleteData,
            			params: {records: Ext.encode(records)},
            			success:function(r){ 
            				var m = Ext.decode(r.responseText);
            				this.loadWithFeedback();
            				this.feedback(m.flash);
            			},
            			scope:this
            		});
              }
            }, this);
          }
        }
      JS
      :submit => <<-JS.l,
        function(){

          var newRecords = [];
          if (this.store.newRecords){
        		Ext.each(this.store.newRecords, function(r){
        		  newRecords.push(r.getChanges())
        		  r.commit() // commit the changes, so that they are not picked up by getModifiedRecords() further down
        		}, this);
        		delete this.store.newRecords;
        	}
      		
        	var updatedRecords = [];
      		Ext.each(this.store.getModifiedRecords(),
      			function(record) {
      				var completeRecordData = {};
      				Ext.apply(completeRecordData, Ext.apply(record.getChanges(), {id:record.get('id')}));
      				updatedRecords.push(completeRecordData);
      			}, 
      		this);
          
          if (newRecords.length > 0 || updatedRecords.length > 0) {
        		Ext.Ajax.request({
        			url:this.initialConfig.interface.postData,
        			params: {
        			  updated_records: Ext.encode(updatedRecords), 
        			  created_records: Ext.encode(newRecords),
        			  filters: this.store.baseParams.filters
        			},
        			success:function(response){
        				var m = Ext.decode(response.responseText);
        				if (m.success) {
        					this.loadWithFeedback();
        					this.store.commitChanges();
        					this.feedback(m.flash);
        				} else {
        					this.feedback(m.flash);
        				}
        			},
        			failure:function(response){
        				this.feedback('Bad response from server');
        			},
        			scope:this
        		});
          }
          
        }
      JS
   
      :refresh_click => <<-JS.l,
        function() {
          // console.info(this);
          if (this.fireEvent('refresh', this) !== false) this.loadWithFeedback();
        }
      JS
      
      :on_column_resize => <<-JS.l,
        function(index, size){
          // var column = this.getColumnModel().getDataIndex(index);
          Ext.Ajax.request({
            url:this.initialConfig.interface.resizeColumn,
            params:{
              index:index,
              size:size
            }
          })
        }
      JS
      
      :on_column_move => <<-JS.l
        function(oldIndex, newIndex){
          Ext.Ajax.request({
            url:this.initialConfig.interface.moveColumn,
            params:{
              old_index:oldIndex,
              new_index:newIndex
            }
          })
        }
      JS
      
    }
  end
end