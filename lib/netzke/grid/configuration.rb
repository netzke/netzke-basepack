module Netzke
  module Grid
    # Overridable methods related to configuration of Grid. For example, to add a custom action to the end of the grid's
    # bbar, you can do:
    #
    #     def bbar
    #       super + [:my_action]
    #     end
    module Configuration # WTF: naming it Config causes troubles in 1.9.3
      extend ActiveSupport::Concern

      module ClassMethods
        def server_side_config_options
          super + [:scope]
        end
      end

      def bbar
        config.has_key?(:bbar) ? config[:bbar] : default_bbar
      end

      def default_bbar
        [].tap do |bbar|
          bbar << :add if has_add_action?
          bbar << :add_in_form if has_add_in_form_action?
          bbar << :edit if has_edit_action?
          bbar << :edit_in_form if has_edit_in_form_action?
          bbar << :apply if has_apply_action?
          bbar << :delete if has_delete_action?
          bbar << :search if has_search_action?
        end
      end

      def context_menu
        config.has_key?(:context_menu) ? config.context_menu : default_context_menu
      end

      def default_context_menu
        [].tap do |menu|
          menu << :edit if has_edit_action?
          menu << :delete if has_delete_action?
        end
      end

      def tools
        config.has_key?(:tools) ? config.tools : default_tools
      end

      def default_tools
        [{ type: :refresh, handler: f(:netzke_on_refresh_tool) }]
      end

      def configure_client(c)
        super
        c.title ||= model.name.pluralize
        c.columns = {items: js_columns}
        c.columns_order = columns_order
        c.pri = model_adapter.primary_key
        if c.default_filters
          populate_columns_with_filters(c)
        end
      end

      def validate_config(c)
        raise ArgumentError, "Grid requires a model" if model.nil?

        c.editing = :in_form if c.editing.nil?

        c.edits_in_form = [:both, :in_form].include?(c.editing)
        c.edits_inline = [:both, :inline].include?(c.editing)

        if c.paging.nil?
          c.paging = c.edits_inline ? :pagination : :buffered
        end

        if c.paging == :buffered && c.edits_inline
          raise ArgumentError, "Buffered grid cannot have inline editing"
        end

        c.tools = tools
        c.bbar = bbar
        c.context_menu = context_menu

        super
      end
    end
  end
end
