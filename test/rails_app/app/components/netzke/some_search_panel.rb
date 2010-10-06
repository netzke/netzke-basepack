module Netzke
  class SomeSearchPanel < Basepack::SearchPanel
    def config
      orig = super
      {
        :model => "User",
        :title => "Some Search Panel",
        :items => [{:name => :first_name.like}, {:name => :created_at.gt}]
      }.deep_merge orig
    end

    def normalize_attr(a)
      if a.is_a?(Symbol) || a.is_a?(String) 
        a.merge(:name => a.to_s, :operator => default_operator)
      else 
        value = a[:name]
        if value.is_a?(MetaWhere::Column)
          a.merge(:name => value.column, :operator => value.method)
        else
          a.merge(:name => value.to_s, :operator => default_operator)
        end
      end
    end
    
    def normalize_item(item)
      item.is_a?(String) || item.is_a?(Symbol) ? {:name => item.to_s, :operator => default_operator} : item.is_a?(Hash) && item[:name].is_a?(MetaWhere::Column) ? item.merge(:name => item[:name].column, :operator => item[:name].method) : item
    end
    
    private
      def default_operator
        "gt"
      end
  end
end