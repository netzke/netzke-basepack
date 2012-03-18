# NOTE: not used
class BookGridWithPaging < Netzke::Basepack::GridPanel
  js_property :title, "Books with paging"
  model "Book"

  def configure
    super
    @config[:rows_per_page] = 2
  end
end
