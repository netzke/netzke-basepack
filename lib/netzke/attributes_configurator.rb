module Netzke
  # == AttributesConfigurator
  # Provides dynamic configuring of attributes for a specific model. This will be picked up by Grid/FormPanels as defaults.
  # Configuration parameters:
  # * <tt>:model</tt> - model to configure attributes for
  class AttributesConfigurator < JsonArrayEditor
    api :load_defaults

    def default_columns
      [{
        :name => "id",
        :attr_type => :integer
      },{
        :name => "included",
        :attr_type => :boolean,
        :default_value => true
      },{
        :name => "name",
        :attr_type => :string,
        :width => 200,
        :editor => {
          :xtype => :combo, 
          :store => config[:model].constantize.netzke_attributes.map{ |attr| attr[:name] },
          :force_selection => true
        }
      },{
        :name => "label",
        :attr_type => :string,
        :width => 200
      },{
        :name => "default_value",
        :attr_type => :string,
        :width => 200
      },{
        :name => "combobox_options",
        :attr_type => :string,
        :width => 200,
        :editor => :textarea
      },{
        :name => "read_only",
        :attr_type => :boolean,
        :default_value => false,
        :header => "R/O"
      },{
        :name => "position",
        :attr_type => :integer,
        :included => false
      },{
        :name => "attr_type",
        :attr_type => :string,
        :meta => :true
      }]
    end
    
    def default_config
      super.deep_merge({
        :name              => 'columns',
        :header                 => false,
        :enable_extended_search => false,
        :enable_edit_in_form    => false,
        :enable_pagination      => false,
        :enable_rows_reordering => GridPanel.rows_reordering_available
      })
    end
    
    def config_tool_needed?
      false
    end
    
    action :defaults, {:text => 'Restore defaults', :icon => :wand} 
    
    def default_bbar
      %w{ add edit apply del - defaults }
    end
        
    def self.js_properties
      {
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            
            // Automatically set the correct editor for the default_value column
            this.on('beforeedit', function(e){
              var column = this.getColumnModel().getColumnById(this.getColumnModel().getColumnId(e.column));
              var record = this.getStore().getAt(e.row);
              
              if (column.dataIndex === "default_value") {
                if (record.get("name") === this.pri) {
                  // Don't allow setting default value for the primary key
                  column.setEditor(null);
                } else {
                  // Auto set the editor, dependent on the field type
                  var attrType = record.get("attr_type");
                  column.setEditor(Ext.create({xtype: this.attrTypeEditorMap[attrType] || "textfield"}));
                }
              }
            }, this);
            
            // Add push menu item to column context menus
            this.on("viewready", this.extendColumnMenu, this);
          }
        END_OF_JAVASCRIPT
        
        :extend_column_menu => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.getView().hmenu.add("-", {text: "Propagate", handler: this.onPushToViews, scope: this});
          }
        END_OF_JAVASCRIPT
        
        :on_push_to_views => <<-END_OF_JAVASCRIPT.l,
          function(){
            var columnIndex = this.getView().hdCtxIndex,
                dataIndex   = this.getColumnModel().getDataIndex(columnIndex);
                
            this.pushDefaultsForAttr({name: dataIndex});
          }
        END_OF_JAVASCRIPT
        
        :on_defaults => <<-END_OF_JAVASCRIPT.l,
          function(){
            Ext.Msg.confirm('Confirm', 'Are you sure?', function(btn){
              if (btn == 'yes') {
                this.loadDefaults();
              }
            }, this);
          }
        END_OF_JAVASCRIPT
      }
    end
    
    api :push_defaults_for_attr
    def push_defaults_for_attr(params)
      NetzkeFieldList.update_children_on_attr(config[:model], params[:name])
      {:feedback => "Done."}
    end
    
    def load_defaults(params)
      data_class.replace_data(default_model_attrs)
      on_data_changed
      {:load_store_data => get_data}
    end
   
    private
      # An override
      def process_data(data, operation)
        if operation == :update
          meta_attrs_to_update = data.inject({}) do |r,el|
            r.merge({
              data_class.find(el["id"]).name => el.reject{ |k,v| k == "id" }
            })
          end

          res = super
          NetzkeModelAttrList.update_fields(config[:model], meta_attrs_to_update)
          # NetzkeFieldList.update_children(config[:model], meta_attrs_to_update)
          res
        else
          # NetzkeModelAttrList.add_attrs(config[:model], data.reject{ |k,v| k == "id" })
          super
        end
      end
    
      # An override
      def store_data(data)
        NetzkeModelAttrList.update_list_for_current_authority(config[:model], data)
        # Let's try to do it through process_data
        # NetzkeFieldList.write_attrs_for_model(config[:model], data)
      end
      
      # An override
      def initial_data
        # NetzkeModelAttrList.attrs_for_model(config[:model])
        NetzkeModelAttrList.read_list(config[:model]) || default_model_attrs
        # NetzkeModelAttrList.read_attrs_for_model(config[:model]) || default_model_attrs
      end
      
      # Default model attributes, along with their defaults meta-attributes (like :label)
      def default_model_attrs
        @default_model_attrs ||= begin
          config[:model].constantize.netzke_attributes.map do |attr| 
            attr.merge(
              :label => attr[:label] || attr[:name].humanize,
              :attr_type => attr[:attr_type].to_s
            )
          end
        end
      end
  end
end