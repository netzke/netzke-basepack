module Grid
  class ActionColumn < Netzke::Basepack::Grid
    include Netzke::Basepack::ActionColumn

    def configure(c)
      c.model = "Book"
      super

      c.columns = [:title, :basic_actions, :extra_actions]
    end

    column :basic_actions do |c|
      c.type = :action
      c.actions = [{name: :delete_row, tooltip: "Delete row", icon: :delete}]
    end

    # Just for illustation (no handlers assigned)
    column :extra_actions do |c|
      c.type = :action
      c.actions = [:information, :error]
    end

    js_configure do |c|
      c.on_delete_row = <<-JS
        function(grid, rowIndex, colIndex){
          this.getSelectionModel().select(rowIndex);
          this.onDel();
        }
      JS
    end
  end
end
