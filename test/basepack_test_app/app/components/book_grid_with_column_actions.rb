# Implements a column action :delete_row
class BookGridWithColumnActions < Netzke::Basepack::GridPanel
  include Netzke::Basepack::ActionColumn

  model "Book"

  column_action :delete_row, :icon => "#{Netzke::Core.ext_uri}/resources/themes/images/default/tree/drop-no.gif"

  js_configure do |c|
    c.on_delete_row = <<-JS
      function(record){
        this.getSelectionModel().select(record);
        this.onDel();
      }
    JS
  end
end
