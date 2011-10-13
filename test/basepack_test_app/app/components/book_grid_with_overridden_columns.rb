class BookGridWithOverriddenColumns < Netzke::Basepack::GridPanel
  model "Book"

  # First way to override a column
  override_column :title, :renderer => "uppercase"

  # Second way to override a column
  # def default_config
  #   super.tap do |c|
  #     c[:override_columns] = {
  #       :title => {:renderer => "uppercase"}
  #     }
  #   end
  # end
end