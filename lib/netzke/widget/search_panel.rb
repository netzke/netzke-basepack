module Netzke::Widget
  # SearchPanel
  # 
  # FormPanel-based widget that allows create configurable searchlogic-compatible searches. 
  # Pretty much work in progress.
  class SearchPanel < FormPanel
    
    # Something like [:equals, :greater_than_or_equal_to, :does_not_equal, :less_than, :less_than_or_equal_to, :greater_than, :ends_with, :like, :begins_with, :empty, :null]
    # CONDITIONS = [:COMPARISON_CONDITIONS, :WILDCARD_CONDITIONS, :BOOLEAN_CONDITIONS].inject([]){|r, c| r + Searchlogic::NamedScopes::Conditions.const_get(c).keys} 
    CONDITIONS = [:equals, :greater_than_or_equal_to, :does_not_equal, :less_than, :less_than_or_equal_to, :greater_than, :ends_with, :like, :begins_with, :empty, :null]
    
    def default_config
      super.merge({
        :model => @passed_config[:search_class_name]
      })
    end
    
    def independent_config
      super.deep_merge(
        :tbar => [
          # TODO: 2010-09-14
          # "Presets:", 
          # {
          #   :xtype => "combo", 
          #   :fieldLabel => "Presets",
          #   :triggerAction => "all",
          #   :store => (persistent_config[:saved_searches] || []).map{ |s| s["name"] },
          #   :id => "presets-combo",
          #   :listeners => {:before_select => {
          #     :fn => "function(combo, record){Ext.getCmp('#{global_id}').selectPreset(record.data.field1);}".l
          #   }}
          # }, 
          :save, :del]
      )
    end
    
    def actions
      super.merge(
        :save => {:text => "Save", :icon => Netzke::Widget::Base.config[:with_icons] && (Netzke::Widget::Base.config[:icons_uri] + "disk.png")},
        :del => {:text => "Delete", :icon => Netzke::Widget::Base.config[:with_icons] && (Netzke::Widget::Base.config[:icons_uri] + "delete.png")}
      )
    end
    
    def self.js_properties
      {
        :remove_search_from_list => <<-END_OF_JAVASCRIPT.l,
          function(name){
            var presetsCombo = Ext.getCmp("presets-combo");
            var presetsComboStore = presetsCombo.getStore();
            presetsComboStore.removeAt(presetsComboStore.find('field1', name));
            presetsCombo.reset();
            this.getForm().reset();
          }
        END_OF_JAVASCRIPT
        
        :set_values => <<-END_OF_JAVASCRIPT.l,
          function(values){
            this.getForm().setValues(Ext.decode(values));
          }
        END_OF_JAVASCRIPT
        
        :select_preset => <<-END_OF_JAVASCRIPT.l,
          function(name){
            this.getForm().reset();
            this.loadSearch({name: name});
          }
        END_OF_JAVASCRIPT
        
        :on_save => <<-END_OF_JAVASCRIPT.l,
          function(){
            var searchName = Ext.getCmp("presets-combo").getValue();
            if (searchName !== "") {
              var presetsComboStore = Ext.getCmp("presets-combo").getStore();
              if (presetsComboStore.find('field1', searchName) !== -1) {
                Ext.Msg.confirm("Overwriting preset '" + searchName + "'", "Are you sure you want to overwrite this preset?", function(btn, text){
                  if (btn == 'yes') {
                     this.doSavePreset(searchName);
                  }
                }, this);
              } else {
                this.doSavePreset(searchName);
                presetsComboStore.add(new presetsComboStore.recordType({field1: searchName}));
              }
            }
          }
        END_OF_JAVASCRIPT
        
        :do_save_preset => <<-END_OF_JAVASCRIPT.l,
          function(name){
            var values = this.getForm().getValues();
            for (var k in values) {
              if (values[k] == "") {delete values[k]}
            }
          
            this.saveSearch({
              name: name,
              values: Ext.encode(values)
            });
          }
        END_OF_JAVASCRIPT
        
        :on_del => <<-END_OF_JAVASCRIPT.l,
          function(){
            var searchName = Ext.getCmp("presets-combo").getValue();
            if (searchName !== "") {
              Ext.Msg.confirm("Deleting preset '" + searchName + "'", "Are you sure you want to delete this preset?", function(btn, text){
                if (btn == 'yes') {
                  this.deleteSearch({
                    name: searchName
                  });
                }
              }, this);
            }
          }
        END_OF_JAVASCRIPT
        
      }
    end
    
    api :save_search
    def save_search(params)
      saved_searches = persistent_config[:saved_searches] || []
      existing = saved_searches.detect{ |s| s["name"] == params[:name] }
      values = ActiveSupport::JSON.decode(params[:values])
      if existing
        existing["values"].replace(values)
      else
        saved_searches << {"name" => params[:name], "values" => values}
      end
      persistent_config[:saved_searches] = saved_searches
      {:feedback => "Preset successfully saved"}
    end
    
    api :delete_search
    def delete_search(params)
      saved_searches = persistent_config[:saved_searches]
      saved_searches.delete_if{ |s| s["name"] == params[:name] }
      {:feedback => "Preset successfully deleted", :remove_search_from_list => params[:name]}
    end
    
    api :load_search
    def load_search(params)
      saved_searches = persistent_config[:saved_searches]
      the_search = saved_searches.detect{ |s| s["name"] == params[:name] }
      
      {:set_values => the_search["values"].to_json}
    end
    
    def initial_fields(only_included = true)
      res = super

      res.reject!{ |f| f[:virtual] }
      
      res.each do |f|
        f.merge!(:condition => "like", :default_value => nil)
        f.merge!(:xtype => xtype_for_attr_type(:string), :attr_type => "string") if f[:name].to_s.index("__")
        f.merge!(:condition => "greater_than") if [:datetime, :integer, :date].include?(f[:attr_type])
        f.merge!(:condition => "equals") if f[:attr_type] == :boolean
      end

      res
    end
    
    # columns to be displayed by the FieldConfigurator (which is GridPanel-based)
    def self.meta_columns
      [                                         
        {:name => "hidden",      :attr_type => :boolean, :editor => :checkbox, :width => 50},
        {:name => "name",        :attr_type => :string,  :editor => :combobox},
        {:name => "condition",   :attr_type => :string,  :editor => {:xtype => :combo, :store => CONDITIONS}},
        {:name => "field_label", :attr_type => :string},
        {:name => "xtype",       :attr_type => :string},
        {:name => "value",       :attr_type => :string},
      ]
    end

    # tweaking the form fields at the last moment
    def js_config
      super.merge({
        :items => fields.map{ |c| c.merge({
          :label => "#{c[:label] || c[:name]} #{c[:condition]}".humanize,
          :name => "#{c[:name]}_#{c[:condition]}"
        })}
      })
    end
    
    private
      # we need to correct the queries to cut off the condition suffixes, otherwise the FormPanel gets confused
      def get_combobox_options(params)
        column_name = params[:column]
        CONDITIONS.each { |c| column_name.sub!(/_#{c}$/, "") }
        super(:column => column_name)
      end
      
      def attr_type_to_xtype_map
        super.merge({
          :boolean => :tricheckbox
        })
      end
    
  end
end