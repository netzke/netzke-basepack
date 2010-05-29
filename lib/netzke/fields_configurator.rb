module Netzke
  # == FieldsConfigurator
  # Provides dynamic configuring columns/fields for GridPanel and FormPanel.
  # Configuration parameters:
  # * <tt>:widget</tt> - widget to configure columns/fields for
  class FieldsConfigurator < JsonArrayEditor
    api :load_defaults

    def default_config
      super.deep_merge({
        :name              => 'columns',
        :ext_config        => {
          :mode => :config,
          :header => false,
          :enable_extended_search => false,
          :enable_edit_in_form => false,
          :enable_rows_reordering => GridPanel.config[:rows_reordering_available],
          :enable_pagination => false
        }
      })
    end
    
    def actions
      super.merge(
        :defaults => {:text => 'Restore defaults'}
      )
    end
    
    def default_bbar
      %w{ add edit apply del - defaults }
    end
        
    def default_columns
      [
        {:name => "id", :attr_type => :integer}, 
        {:name => "position", :attr_type => :integer, :included => false},
        {:name => "attr_type", :attr_type => :string, :meta => true},
        *config[:owner].class.meta_columns
      ]
    end
        
    def self.js_extend_properties
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
   
    # Don't show the config tool
    # def config_tool_needed?
    #   false
    # end
   
    private
      # An override
      def store_data(data)
        NetzkeFieldList.write_list(config[:owner].global_id, data)
      end
      
      # An override
      def initial_data
        NetzkeFieldList.read_list(config[:owner].global_id) || default_owner_fields
      end
      
      def default_owner_fields
        config[:owner].initial_columns(false).map(&:deebeefy_values)
        # NetzkeFieldList.read_list("#{config[:owner].data_class.name.tableize}_model_fields") || normalize_columns(config[:owner].initial_columns.map{ |c| c.merge(:attr_type => c[:attr_type]) }).map(&:deebeefy_values)
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