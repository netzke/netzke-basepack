module Netzke
  module Grid
    # Child components for Grid and Tree
    module Components
      extend ActiveSupport::Concern

      included do
        component :add_window do |c|
          configure_form_window(c)
          c.title = "Add #{model_class.model_name.human}"
          c.items = [:add_form]
          c.form_config.record = model_class.new(columns_default_values)
          c.excluded = !allowed_to?(:create)
        end

        component :edit_window do |c|
          configure_form_window(c)
          c.title = "Edit #{model_class.model_name.human}"
          c.items = [:edit_form]
          c.excluded = !allowed_to?(:update)
        end

        component :multi_edit_window do |c|
          configure_form_window(c)
          c.title = "Edit #{model_class.model_name.human.pluralize}"
          c.items = [:multi_edit_form]
          c.excluded = !allowed_to?(:update)
        end

        component :search_window do |c|
          c.klass = Basepack::SearchWindow
          c.model = config.model
          c.fields = attributes_for_search
        end
      end

      def configure_form_window(c)
        c.klass = Basepack::RecordFormWindow
        c.form_config = ActiveSupport::OrderedOptions.new
        configure_form(c.form_config)
      end

      def configure_form(c)
        shared_config = %w(model mode persistent_config strong_values).reduce({}) do |r, m|
          r.merge!(m.to_sym => config.send(m))
        end

        c.merge!(shared_config)
        c.attribute_overrides = attribute_overrides
        c.items = form_items
      end
    end
  end
end
