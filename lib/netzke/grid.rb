module Netzke
  # Functionality:
  # * data operations - get, post, delete, create
  # * column resize and move
  # * permissions
  # * sorting - TODO
  # * pagination - TODO
  # * validation - TODO
  # * properties and column configuration
  #
  class Grid < Base
    # define connection points between client side and server side of Grid. See implementation of equally named methods below.
    interface :get_data, :post_data, :delete_data, :resize_column, :move_column

    def initial_config
      {:ext_config => {:properties => true}}
    end

    def property_widgets
      [{
        :columns => {
          :widget_class_name => "Grid", 
          :data_class_name => column_manager_class_name, 
          :ext_config => {:title => false, :properties => false},
          :active => true
        }
      },{
        :general => {
          :widget_class_name => "PreferenceGrid", 
          :host_widget_name => @id_name, 
          :default_properties => available_permissions.map{ |k| {:name => "permissions.#{k}", :value => @permissions[k.to_sym]}},
          :ext_config => {:title => false}
        }
      }]
    end

    def get_records(conditions = nil)
      raise ArgumentError, "No data_class_name specified for widget '#{config[:name]}'" if !config[:data_class_name]
      records = config[:data_class_name].constantize.find(:all, :conditions => conditions)
      output_array = []
      records.each do |r|
        r_array = []
        self.get_columns.each do |column|
          r_array << r.send(column[:name])
        end
        output_array << r_array
      end
      output_array
    end
    
    # get columns from layout manager
    def get_columns
      return nil if config[:layout_manager] == false # TODO: also return nil if we don't have the Layout or GridColumn class

      layout = layout_manager_class.by_widget(id_name)
      
      layout ||= column_manager_class.create_layout_for_widget(self)
      
      layout.items_hash
    end
    
    ## API
    def post_data(params = {})
      data = JSON.parse(params.delete(:updated_records))
      if !data.empty?
        if @permissions[:update]
          # log.info { "!!! data: #{data.inspect}" }
          klass = config[:data_class_name].constantize
          updated_records = 0
          data.each do |record|
            if existing_record = klass.find_by_id(record['id'])
              updated_records += 1 if existing_record.update_attributes(record)
            else
            end
          end
          flash :notice => "Updated #{updated_records} records"
        else
          flash :error => "You don't have permissions to update data"
        end
      end
      
      data = JSON.parse(params.delete(:new_records))
      if !data.empty?
        if @permissions[:create]
          # log.info { "!!! data: #{data.inspect}" }
          klass = config[:data_class_name].constantize
          updated_records = 0
          data.each do |record|
            if existing_record = klass.create(record)
              updated_records += 1 # if existing_record.update_attributes(record)
            else
            end
          end
          flash :notice => "Created #{updated_records} records"
        else
          flash :error => "You don't have permissions to add new data"
        end
      end
      {:success => true, :flash => @flash}
    end
    
    def get_data(params = {})
      if @permissions[:read]
        records = get_records(params[:filters])
        # records.to_json
        {:data => records, :total => records.size}
      else
        flash :error => "You don't have permissions to read data"
        {:success => false, :flash => @flash}
      end
    end

    def delete_data(params = {})
      if @permissions[:delete]
        record_ids = JSON.parse(params.delete(:records))
        klass = config[:data_class_name].constantize
        klass.delete(record_ids)
        flash :notice => "Deleted #{record_ids.size} record(s)"
        success = true
      else
        flash :error => "You don't have permissions to delete data"
        success = false
      end
      {:success => success, :flash => @flash}
    end

    def resize_column(params)
      raise "Called interface_resize_column while not configured to do so" unless config[:column_resize]
      l_item = layout_manager_class.by_widget(id_name).layout_items[params[:index].to_i]
      l_item.width = params[:size]
      l_item.save!
      {}
    end
    
    def move_column(params)
      raise "Called interface_move_column while not configured to do so" unless config[:column_move]
      layout_manager_class.by_widget(id_name).move_item(params[:old_index].to_i, params[:new_index].to_i)
      {}
    end


    ## Data for properties grid
    def properties__columns__get_data(params = {})
      columns_widget = aggregatee_instance(:properties__columns)

      layout_id = layout_manager_class.by_widget(id_name).id
      columns_widget.interface_get_data(params.merge(:filters => {:layout_id => layout_id}))
    end
    
    def properties__general__load_source(params = {})
      w = aggregatee_instance(:properties__general)
      w.interface_load_source(params)
    end
    
    # we pass column config at the time of instantiating the JS class
    def js_config
      res = super
      res.merge!(:columns => get_columns || config[:columns]) # first try to get columns from DB, then from config
      res.merge!(:data_class_name => config[:data_class_name])
      res
    end

    def js_listeners
      super.merge({
        :columnresize => (config[:column_resize] ? {:fn => "this.onColumnResize".l, :scope => this} : nil),
        :columnmove => (config[:column_move] ? {:fn => "this.onColumnMove".l, :scope => this} : nil)
      })
    end


    protected
    
    def layout_manager_class_name
      "NetzkeLayout"
    end
    
    def layout_manager_class
      layout_manager_class_name.constantize
    rescue NameError
      nil
    end
    
    def column_manager_class_name
      "NetzkeGridColumn"
    end
    
    def column_manager_class
      column_manager_class_name.constantize
    rescue NameError
      nil
    end
    
    def available_permissions
      %w(read update create delete)
    end

    #
    # JS class generation section
    #
    
    public
    
    def js_base_class 
      'Ext.grid.EditorGridPanel'
    end

    def js_default_config
      super.merge({
        :store => "ds".l,
        :cm => "cm".l,
        :sel_model => "new Ext.grid.RowSelectionModel()".l,
        :auto_scroll => true,
        :click_to_edit => 2,
        :track_mouse_over => true,
        :bbar => "config.actions".l,
        
        #custom configs
        :auto_load_data => true
      })
    end
    
    def js_before_constructor
      <<-JS
      this.recordConfig = [];

    	if (!config.columns) {
    	  this.feedback('No columns defined for grid #{id_name}');
  	  }

      Ext.each(config.columns, function(column){this.recordConfig.push({name:column.name})}, this);
      this.Row = Ext.data.Record.create(this.recordConfig);
      var ds = new Ext.data.Store({
          proxy: this.proxy = new Ext.data.HttpProxy({url:config.interface.getData}),
          reader: new Ext.data.ArrayReader({root: "data", totalProperty: "total", successProperty: "succes", id:0}, this.Row)
      });

      this.cmConfig = [];
      Ext.each(config.columns, function(c){
        var editor = c.readOnly ? null : new Ext.form.TextField({selectOnFocus:true})
        this.cmConfig.push({
          header: c.label || c.name,
          dataIndex: c.name,
          hidden: c.hidden,
          width: c.width,
          editor: editor
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
            this.loadWithFeedback()
          }
        }
        JS
      
        :load_with_feedback => <<-JS.l,
          function(){
        	  var exceptionHandler = function(proxy, options, response, error){
              // console.info(error);
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
        		}, scope:this});
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
          			  new_records: Ext.encode(newRecords),
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
    
    def tools
      [{:id => 'refresh', :on => {:click => 'refreshClick'}}]
    end

    def actions
      [{
        :text => 'Add', :handler => 'add', :disabled => @pref['permissions.create'] == false
      },{
        :text => 'Edit', :handler => 'edit', :disabled => @pref['permissions.update'] == false
      },{
        :text => 'Delete', :handler => 'delete', :disabled => @pref['permissions.delete'] == false
      },{
        :text => 'Apply', :handler => 'submit', :disabled => @pref['permissions.update'] == false && @pref['permissions.create'] == false
      }]
    end

    # Uncomment to enable a menu duplicating the actions
    # def js_menus
    #   [{:text => "config.dataClassName".l, :menu => "config.actions".l}]
    # end
    
    # include ColumnOperations
    include PropertiesTool # it will load aggregation with name :properties into a modal window
  end
end