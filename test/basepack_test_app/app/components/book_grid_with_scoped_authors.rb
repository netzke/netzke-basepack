# NOTE: not used
class BookGridWithScopedAuthors < Netzke::Basepack::GridPanel

  model "Book"

  def configure(c)
    super
    c.columns = [:title, {:name => :author__first_name, :scope => lambda{ |r| r.where("first_name LIKE ?", "%tom%")}}]
  end

end
