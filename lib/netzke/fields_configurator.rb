module Netzke
  # == FieldsConfigurator
  # Provides dynamic configuring columns/fields for GridPanel and FormPanel.
  # Configuration parameters:
  # * <tt>:component</tt> - component to configure columns/fields for
  class FieldsConfigurator < JsonArrayEditor
    api :load_defaults

    def default_config
      super.deep_merge({
        :name              => 'columns',
        :ext_config        => {
          :config_tool => false,
          :header => false,
          :enable_extended_search => false,
          :enable_edit_in_form => false,
          :enable_rows_reordering => GridPanel.rows_reordering_available,
          :enable_pagination => false
        }
      })
    end
    
    action :defaults, {:text => 'Restore defaults', :icon => :wand} 
    
    def default_bbar
      %w{ add edit apply del }.map(&:action) + "-" + [:defaults.action]
    end
        
    # Default columns for the configurator
    def default_columns
      [
        {:name => "id", :attr_type => :integer, :meta => true}, 
        {:name => "position", :attr_type => :integer, :meta => true},
        {:name => "attr_type", :attr_type => :string, :meta => true},
        *config[:owner].class.meta_columns.map { |c| c[:name] == "name" ? inject_combo_for_name_column(c) : c }
      ]
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
            
          }
        END_OF_JAVASCRIPT
        
        :attr_type_editor_map => {
          :integer  => "numberfield",
          :boolean  => "checkbox",
          :decimal  => "numberfield",
          :datetime => "xdatetime",
          :date     => "datefield",
          :string   => "textfield"
        },
        
        # Disable the 'gear' tool for now
        :on_gear => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.feedback("You can't configure configurator (yet)");
          }
        END_OF_JAVASCRIPT
        
        # we need to provide this function so that the server-side commit would happen
        :get_commit_data => <<-END_OF_JAVASCRIPT.l,
          function(){
            return null; // because our commit data is already at the server
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
    
    def load_defaults(params)
      # Reload the temp table with default values
      data_class.replace_data(default_owner_fields)

      # ... and reflect it in the persistent storage
      on_data_changed
      
      # Update the grid
      {:load_store_data => get_data}
    end
   
    # Never show the config tool
    def config_tool_needed?
      false
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
      
          NetzkeFieldList.update_fields(config[:owner].global_id, meta_attrs_to_update)
        
          res
        else
          super
        end
      end
    
      # An override
      def store_data(data)
        NetzkeFieldList.update_list_for_current_authority(config[:owner].global_id, data, config[:owner].data_class.name)
      end
      
      # An override
      def initial_data
        NetzkeFieldList.read_list(config[:owner].global_id) || default_owner_fields
      end

      # Set strict combo for the "name" column, with options of the attributes provided by the data_class
      def inject_combo_for_name_column(c)
        netzke_attrs = config[:owner].data_class.netzke_attributes.map{ |a| a[:name] }
        c.merge(:editor => {:xtype => :combo, :store => netzke_attrs, :force_selection => true})
      end
      
      def default_owner_fields
        config[:owner].initial_columns(false).map(&:deebeefy_values)
      end
   
      # This is an override of GridPanel#on_data_changed
      def on_data_changed
        # Default column settings taken from 
        defaults_hash = config[:owner].class.meta_columns.inject({}){ |r, c| r.merge!(c[:name] => c[:default_value]) }
        stripped_columns = data_class.all_columns.map do |c| 
          # reject all keys that are 1) same as defaults
          c.reject{ |k,v| defaults_hash[k.to_sym].to_s == v.to_s } 
        end
        store_data(stripped_columns)
      end
   
  end
end