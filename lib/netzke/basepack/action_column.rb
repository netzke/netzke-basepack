module Netzke
  module Basepack
    # An extension for {Grid} that allows specifying (multiple) action columns.
    # Example:
    #
    #     class Books < Netzke::Basepack::Grid
    #       include Netzke::Basepack::ActionColumn
    #
    #       def configure(c)
    #         c.model = "Book"
    #         super
    #       end
    #
    #       def columns
    #         super + [:basic_actions, :extra_actions]
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
    #       js_configure do |c|
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

      included do |base|
        js_configure do |c|
          c.require :action_column
        end
      end

      # This can be optimized in order to generate less json in the column getter
      def augment_column_config(c)
        if c[:type] == :action
          c.xtype = :netzkeactioncolumn

          c[:getter] = lambda do |r|
            c.actions.map {|a| build_action_config(a)}.netzke_jsonify.to_json
          end
        end

        super
      end

    private

      def build_action_config(a)
        a = {name: a} if a.is_a?(Symbol)
        a.tap do |a|
          a[:tooltip] ||= a[:name].to_s.humanize
          a[:icon] ||= a[:name].to_sym
          a[:handler] ||= "on_#{a[:name]}"

          a[:icon] = "#{Netzke::Core.icons_uri}/#{a[:icon]}.png" if a[:icon].is_a?(Symbol)
        end
      end
    end
  end
end
