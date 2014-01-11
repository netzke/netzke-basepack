class BookGridWithOverriddenColumns < Netzke::Basepack::Grid
  model "Book"

  # First way to override a column
  column :title do |c|
    c.renderer = "uppercase"
  end

  # Second way to override a column
  # def default_config
  #   super.tap do |c|
  #     c[:override_columns] = {
  #       :title => {:renderer => "uppercase"}
  #     }
  #   end
  # end
end
