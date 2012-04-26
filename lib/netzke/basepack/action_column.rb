module Netzke
  module Basepack
    module ActionColumn
      extend ActiveSupport::Concern

      included do |base|

        # Returns registered actions
        class_attribute :registered_column_actions
        self.registered_column_actions = []

        js_include :action_column
      end

      module ClassMethods
        # Register an action
        def register_column_action(name)
          self.registered_column_actions |= [name]
        end

        # Use this method to define column actions in your component, e.g.:
        #
        #     column_action :edit, :icon => "/images/icons/edit.png"
        #
        # TODO: List all options.
        # TODO: think how it'll be possible to override individual column_actions (if need to bother at all)
        def column_action(name, params = {})
          params[:name] = name
          params[:column] ||= "actions"
          params[:icon] ||= "/extjs/examples/shared/icons/fam/cog.png"
          params[:tooltip] = params[:tooltip].presence || name.to_s.humanize
          params[:handler] ||= "on_#{name}"
          register_column_action(name);
          define_method "#{name}_column_action" do |record=nil| # TODO: this won't work in Ruby 1.8.7
            params[:row_config] && record ? params.merge(params[:row_config].call(record, self)) : params
          end
        end
      end

      def final_columns(options = {})
        orig_columns = super

        action_column_names = column_actions.map{ |action| action[:column] }.uniq
        action_columns = orig_columns.select{ |c| action_column_names.include? c[:name] }

        # Append the column if none found AND no explicit column configuration was provided
        if action_columns.empty? && !config[:columns]
          action_columns = [{:name => "actions"}.merge(config[:override_columns].try(:fetch, :actions, nil) || {})]
          orig_columns += action_columns
        end

        action_columns.each do |c|
          c[:xtype] = :netzkeactioncolumn
          c[:getter] = lambda do |r|
            self.class.registered_column_actions.select{ |action_name| self.send("#{action_name}_column_action")[:column] == c[:name] }.map{ |action_name| self.send("#{action_name}_column_action", r) }.to_nifty_json
          end
        end

        orig_columns
      end

      def column_actions
        self.class.registered_column_actions.map{ |action_name| self.send("#{action_name}_column_action")}
      end

    end
  end
end
