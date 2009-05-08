module Netzke
  #
  # A widget used for editing a DB table. It contains a grid and a form which may display different DB fields,
  # configured by grid_columns and form_fields configuration options respectively
  #
  class TableEditor < BorderLayoutPanel
    
    def self.js_extend_properties
      super.merge({
        :get_form_widget => <<-JS.l,
          function(){
            return this.getRegionWidget(this.initialConfig.region);
          }
        JS
        
        # a grid row clicked
        :on_row_click => <<-JS.l,
          function(grid, index, e){
            // don't react if the selection hasn't changed
        		if (index == this.lastSelectedRow) return false;
        		this.lastSelectedRow = index;
        		
        		// get id of the record
            var recordId = this.getCenterWidget().getStore().getAt(index).get('id');
            
            // load the form with the record id
            this.getRegionWidget(this.initialConfig.region).loadRecord(recordId);
          }
        JS
        
        # after the form is submitted, reload the grid
        :on_form_actioncomplete => <<-JS.l
          function(grid, index, e){
            this.getRegionWidget('center').store.load()
          }
        JS
      })
    end

    def initial_config
      # don't show the title on the top level
      super.merge!({:ext_config => {:title => false}})
    end

    def js_config
      # the client side of the widget wants to know which region it uses
      super.merge({
        :region => config[:split_region]
      })
    end

    def self.js_after_constructor
      super << <<-JS
        var setCentralWidgetEvents = function(){
          this.getCenterWidget().on('addclick', function(){
            this.getFormWidget().getForm().reset();
          
            var firstEditableField = null;
            this.getFormWidget().getForm().items.each(function(f){
              if (!f.hidden && !f.disabled){
                firstEditableField = f;
                return false; // break the loop
              }
            })
            if (firstEditableField) firstEditableField.focus();

            this.getFormWidget().ownerCt.expand();

            this.getCenterWidget().getSelectionModel().clearSelections();
            this.lastSelectedRow = null;
            return false;
          }, this)
        
          this.getCenterWidget().on('rowclick', this.onRowClick, this);
        };
        this.getCenterWidget().ownerCt.on('add', setCentralWidgetEvents, this);
        setCentralWidgetEvents.call(this);
      JS
    end

    def initial_aggregatees
      split_region  = config[:split_region] || :east
      split_size    = config[:split_size] || 200
      {
        :center => {
          :widget_class_name    => "GridPanel", 
          :data_class_name      => config[:data_class_name], 
          :ext_config           => {
            :title        => config[:grid_title] || config[:data_class_name].pluralize
          }
        }.recursive_merge(config[:grid_config] || {}),
        
        split_region => {
          :widget_class_name    => "FormPanel", 
          :data_class_name      => config[:data_class_name], 
          :region_config        => {
            :width  => split_size, 
            :height => split_size, 
            :split  => true,
            :collapsible => true
          },
          :ext_config => {
            :title        => config[:form_title] || "#{config[:data_class_name]} details",
            :listeners    => {:actioncomplete => {
              :fn => "function(f, a){this.ownerCt.ownerCt.onFormActioncomplete(f,a)}".l
            }}
          }
        }.recursive_merge(config[:form_config] || {})
      }
    end

  end
end