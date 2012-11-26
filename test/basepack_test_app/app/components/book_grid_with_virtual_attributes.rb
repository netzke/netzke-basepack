# This has been excluded from tests in 0-8. In 0-8 the values in the association columns/fields are passed as integers (id of associated record), not as string. So, the author_first_name_setter won't work as planned here.
class BookGridWithVirtualAttributes < Netzke::Basepack::Grid
  include Extras::BookPresentation

  model "Book"

  def columns
    custom_fields
  end

  component :add_window do |c|
    super(c)
    c.form_config.items = custom_fields
  end

  component :edit_window do |c|
    super(c)
    c.form_config.items = custom_fields
  end

  def custom_fields
    [
      :title,
      {:name => "author__first_name", :setter => author_first_name_setter},
      :exemplars,
      {:name => "in_abundance", :getter => in_abundance_getter}
    ]
  end
end
