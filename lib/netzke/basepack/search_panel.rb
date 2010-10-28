module Netzke
  module Basepack
    class SearchPanel < FormPanel
      
      js_properties :header => false,
                    :bbar => false

      # An override
      def normalize_field(f)
        f = if f.is_a?(Symbol) || f.is_a?(String) 
          {:name => f.to_s, :operator => default_operator}
        else 
          search_condition = f[:name]
          if search_condition.is_a?(MetaWhere::Column)
            {:name => search_condition.column, :operator => search_condition.method}
          else
            {:name => search_condition.to_s}
          end
        end
    
        f = super(f)
    
        f[:disabled] = primary_key_attr?(f)
        
        # Association field
        if f[:name].to_s.index("__")
          f[:xtype] ||= xtype_for_attr_type(:string)
          f[:attr_type] = :string
        end
        
        f[:operator] ||= "gt" if [:datetime, :integer, :date].include?(f[:attr_type])
        f[:operator] ||= "eq" if f[:attr_type] == :boolean
        f[:operator] ||= default_operator

        f[:field_label] = [f[:field_label], f[:operator]].join(" ")
        f.merge(:name => [f[:name], f[:operator]].join("__"))
      end
  
      private
        def default_operator
          "like"
        end
        
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
end