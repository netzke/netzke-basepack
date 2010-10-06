module Netzke
  module ActiveRecord
    module RelationExtensions
      def extend_with(scope, *params)
        case scope.class.name
        when "Symbol" # model's scope
          self.send(scope, *params)
        when "String" # MySQL query
          self.where(scope)
        when "Hash"   # conditions hash
          self.where(scope)
        when "Array"  # SQL query with params
          self.where(scope)
        when "Proc"   # receives a relation, must return a relation
          scope.call(self)
        else
          raise ArgumentError, "Wrong parameter type for ActiveRecord::Relation#extend_with"
        end
      end
    end
  end
end