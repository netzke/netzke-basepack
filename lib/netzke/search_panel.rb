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
    
    def initial_fields(only_included = true)
      res = super

      res.reject!{ |f| f[:virtual] }
      
      res.each do |f| 
        f.merge!(:condition => "like", :default_value => nil)
        f.merge!(:xtype => xtype_for_attr_type(:string), :attr_type => "string") if f[:name].to_s.index("__")
        f.merge!(:condition => "greater_than") if [:datetime, :integer, :date].include?(f[:attr_type].to_sym)
        f.merge!(:condition => "equals") if f["attr_type"] == "boolean"
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
        :fields => fields.map{ |c| c.merge({
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