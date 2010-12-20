class LockableBookForm < BookForm
  def default_config
    super.merge(:mode => :lockable)
  end

  def configuration
    sup = super
    sup.merge(
      :items => sup[:items].reject{ |i| i.is_a?(Hash) && i[:name] == :author__first_name } + [{
        :xtype => :compositefield,
        :defaults => {:flex => 1},
        :field_label => "Author name (first, last)",
        :items => [{:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
      }]
    )
  end
end
