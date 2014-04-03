module Netzke
  module Basepack
    module ActiveRecord
      module RelationExtensions
        def extend_with(*params)
          scope = params.shift
          case scope
          when Symbol # model's scope
            self.send(scope, *params)
          when String # SQL query or SQL query with params (e.g. ["created_at < ?", 1.day.ago])
            params.empty? ? self.where(scope) : self.where([scope, *params])
          when Array
            self.extend_with(*scope)
          when Hash  # conditions hash
            self.where(scope)
          when Proc  # receives a relation, must return a relation
            scope.call(self)
          else
            raise ArgumentError, "Wrong parameter type for ActiveRecord::Relation#extend_with"
          end
        end
      end
    end
  end
end
