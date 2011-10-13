class BookGridWithOverriddenColumns < Netzke::Basepack::GridPanel
  model "Book"

  def default_config
    super.tap do |c|
      c[:override_columns] = {
        :title => {:renderer => "uppercase"}
      }
    end
  end
end