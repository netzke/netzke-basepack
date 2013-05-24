class LockableBookForm < BookForm
  # Code from the future
  # field :author__first_name do |c|
  #   c.xtype = :compositefield
  #   c.defaults = {:flex => 1}
  #   c.field_label = "Author name (first, last)"
  #   c.items = [{:name => :author__first_name, :nested_attribute => true}, {:name => :author__last_name, :nested_attribute => true}]
  # end

  def configure(c)
    super
    c.mode = :lockable
  end
end
