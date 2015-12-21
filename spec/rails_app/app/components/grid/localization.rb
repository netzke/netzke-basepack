class Grid::Localization < Netzke::Grid::Base
  def configure(c)
    super
    c.model = "Book"
    c.title = I18n.t "books"
    c.columns = [:author__name, :exemplars]
  end
end
