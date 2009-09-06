module Netzke
  # SearchPanel
  # 
  # FormPanel-based widget that allows create configurable searchlogic-compatible searches. 
  # Pretty much work in progress.
  class SearchPanel < FormPanel
    # Something like [:equals, :greater_than_or_equal_to, :does_not_equal, :less_than, :less_than_or_equal_to, :greater_than, :ends_with, :like, :begins_with, :empty, :null]
    CONDITIONS = [:COMPARISON_CONDITIONS, :WILDCARD_CONDITIONS, :BOOLEAN_CONDITIONS].inject([]){|r, c| r + Searchlogic::NamedScopes::Conditions.const_get(c).keys}
    
    def default_config
      super.merge({
        :data_class_name => @passed_config[:search_class_name]
      })
    end
    
    def default_columns
      res = super

      res.map! do |f| 
        norm_column = normalize_column(f)
        norm_column.merge!({
          :condition => "equals"
        })
        norm_column.merge!(:hidden => true) if norm_column[:name].to_s.index("__")
        
        norm_column
      end
      
      res
    end
    
    # columns to be displayed by the FieldConfigurator (which is GridPanel-based)
    def self.config_columns
      [
        {:name => :hidden, :type => :boolean, :editor => :checkbox, :width => 50},
        {:name => :name, :type => :string, :editor => :combobox},
        {:name => :condition, :type => :string, :editor => {:xtype => :combobox, :options => CONDITIONS}},
        {:name => :field_label, :type => :string},
        {:name => :xtype, :type => :string},
        {:name => :value, :type => :string},
      ]
    end

    # tweaking the form fields at the last moment
    def js_config
      super.merge({
        :clmns => columns.map{ |c| c.merge({
          :field_label => "#{c[:field_label] || c[:name]} #{c[:condition]}".humanize,
          :name => "#{c[:name]}_#{c[:condition]}"
        })}
      })
    end
    
    # we need to correct the queries to cut off the condition suffixes, otherwise the FormPanel gets confused
    def get_combobox_options(params)
      column_name = params[:column]
      CONDITIONS.each { |c| column_name.sub!(/_#{c}$/, "") }
      super(:column => column_name)
    end
    
  end
end