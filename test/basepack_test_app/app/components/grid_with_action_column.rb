class GridWithActionColumn < Netzke::Basepack::Grid
  include Netzke::Basepack::ActionColumn

  def configure(c)
    c.model = "Book"
    super
  end

  column :basic_actions do |c|
    c.type = :action
    c.actions = [{name: :delete_row, tooltip: "Delete row", icon: :delete}]
  end

  # Just for illustation (no handlers assigned)
  column :extra_actions do |c|
    c.type = :action
    c.actions = [:error, :information]
  end

  js_configure do |c|
    c.on_delete_row = <<-JS
      function(record){
        this.getSelectionModel().select(record);
        this.onDel();
      }
    JS
  end
end
