class Grid::Localization < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = "Book"
    c.title = I18n.t "books"
    c.columns = [:author__name, :title]
  end
end
