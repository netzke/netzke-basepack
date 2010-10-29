class SomeSearchPanel < Netzke::Basepack::FormPanel
  def config
    orig = super
    {
      :model => "User",
      :title => "Some Search Panel",
      :items => [{:name => :first_name.like}, {:name => :created_at.gt}]
    }.deep_merge orig
  end

  def normalize_field(f)
    f = if f.is_a?(Symbol) || f.is_a?(String)
      {:name => f.to_s, :operator => default_operator}
    else
      search_condition = f[:name]
      if search_condition.is_a?(MetaWhere::Column)
        {:name => search_condition.column, :operator => search_condition.method}
      else
        {:name => search_condition.to_s, :operator => default_operator}
      end
    end

    f[:disabled] = primary_key_attr?(f)

    f = super(f)

    f.merge(:name => [f[:name], "__", f[:operator]].join)
  end

  private
    def default_operator
      "gt"
    end
end
