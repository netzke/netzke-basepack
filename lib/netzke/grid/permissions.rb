module Netzke
  module Grid
    module Permissions
      def allowed_to?(action)
        return allowed_to_read? if action == :read
        permissions[action].nil? ? !config.read_only : permissions[action]
      end

      def allowed_to_read?
        permissions[:read] != false
      end

      def permissions
        config.permissions || {}
      end
    end
  end
end
