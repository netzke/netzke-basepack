module Netzke
  module Basepack
    # An extension for {Grid} that allows specifying (multiple) action columns.
    # Example:
    #
    #     class Books < Netzke::Grid::Base
    #       include Netzke::Basepack::ActionColumn
    #
    #       def configure(c)
    #         c.model = "Book"
    #         super
    #       end
    #
    #       def columns
    #         super + [:actions]
    #       end
    #
    #       column :actions do |c|
    #         c.type = :action
    #         c.actions = [
    #           # default handler will be on_delete_row
    #           {name: :delete_row, tooltip: "Delete row", icon: :delete}
    #
    #           # feel free to define more actions in this column
    #         ]
    #       end
    #
    #       client_class do |c|
    #         # handler for column action 'delete_row'
    #         c.on_delete_row = <<-JS
    #           function(record){
    #             this.getSelectionModel().select(record);
    #             this.onDel();
    #           }
    #         JS
    #       end
    #     end
    module ActionColumn
      extend ActiveSupport::Concern

      def augment_column_config(c)
        super
        if c.type == :action
          c.xtype = :actioncolumn
          c.items = c.actions.map {|a| build_action_config(a)}.netzke_jsonify
        end
      end

    private

      def build_action_config(a)
        a = {name: a} if a.is_a?(Symbol)
        a[:handler] ||= a[:name]
        a.tap do |a|
          a[:tooltip] ||= a[:name].to_s.humanize
          a[:icon] ||= a[:name].to_sym
          a[:passed_handler] = a[:handler].to_s.camelize
          a[:handler] = f(:handle_column_action)
          a[:icon] = "#{Netzke::Core.icons_uri}/#{a[:icon]}.png" if a[:icon].is_a?(Symbol)
        end
      end
    end
  end
end
