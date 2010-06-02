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
        :model => @passed_config[:search_class_name]
      })
    end
    
    def initial_fields
      res = super

      res.map! do |f| 
        norm_column = normalize_column(f)
        norm_column.merge!({
          :condition => "like"
        })
        # norm_column.merge!(:hidden => true) if norm_column[:name].to_s.index("__") || norm_column[:xtype] == :xcheckbox
        
        norm_column.merge!(:xtype => xtype_for_field_type(:string)) if norm_column[:name].to_s.index("__")
        norm_column.merge!(:condition => "greater_than") if [:datetime, :integer, :date].include?(norm_column[:type])
        norm_column.merge!(:condition => "equals") if [:boolean].include?(norm_column[:type])
        norm_column
      end
      
      res
    end
    
    # columns to be displayed by the FieldConfigurator (which is GridPanel-based)
    def self.meta_columns
      [                                         
        {:name => "hidden",      :type => :boolean, :editor => :checkbox, :width => 50},
        {:name => "name",        :type => :string,  :editor => :combobox},
        {:name => "condition",   :type => :string,  :editor => {:xtype => :combo, :store => CONDITIONS}},
        {:name => "field_label", :type => :string},
        {:name => "xtype",       :type => :string},
        {:name => "value",       :type => :string},
      ]
    end

    # tweaking the form fields at the last moment
    def js_config
      super.merge({
        :clmns => fields.map{ |c| c.merge({
          :field_label => "#{c[:field_label] || c[:name]} #{c[:condition]}".humanize,
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
      
      def field_type_to_xtype_map
        super.merge({
          :boolean => :tricheckbox
        })
      end
    
  end
end