module Grid
  class ActionColumn < Netzke::Grid::Base
    include Netzke::Basepack::ActionColumn

    def configure(c)
      c.model = "Book"
      super

      c.columns = [:title, :basic_actions, :extra_actions]
      c.form_items = [:title]
    end

    column :basic_actions do |c|
      c.type = :action
      c.actions = [{name: :delete_row, tooltip: "Delete row", icon: :delete, is_disabled: f(:every_third_row)}]
    end

    # Just for illustation (no handlers assigned)
    column :extra_actions do |c|
      c.type = :action
      c.actions = [:information, :error]
    end

    client_class do |c|
      c.every_third_row = l(<<-JS)
        function(grid, rowIndex, colIndex, item, record){
          return rowIndex % 3 == 1;
        }
      JS
      c.netzke_on_delete_row = l(<<-JS)
        function(grid, rowIndex, colIndex){
          this.getSelectionModel().select(rowIndex);
          this.netzkeOnDelete();
        }
      JS
    end
  end
end
