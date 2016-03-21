module Netzke
  module Grid
    module Actions
      extend ActiveSupport::Concern

      included do
        action :add do |a|
          a.icon = :add
        end

        action :add_in_form do |a|
          a.icon = :application_form_add
        end

        action :edit do |a|
          a.disabled = true # initial
          a.icon = :table_edit
        end

        action :delete do |a|
          a.disabled = true # initial
          a.icon = :table_row_delete
        end

        action :apply do |a|
          a.icon = :tick
        end

        action :search do |a|
          a.enable_toggle = true
          a.icon = :magnifier
        end

        action :edit_in_form do |a|
          a.disabled = true # initial
          a.icon = :application_form_edit
        end
      end

      def has_add_action?
        allowed_to?(:create)
      end

      def has_add_in_form_action?
        allowed_to?(:create) && config.editing == :both
      end

      def has_edit_action?
        allowed_to?(:update)
      end

      def has_edit_in_form_action?
        allowed_to?(:update) && config.editing == :both
      end

      def has_apply_action?
        config.edits_inline && (allowed_to?(:create) || allowed_to?(:update))
      end

      def has_delete_action?
        allowed_to?(:delete)
      end

      def has_search_action?
        true
      end
    end
  end
end
