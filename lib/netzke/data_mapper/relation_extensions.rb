module Netzke
  module DataMapper
    module RelationExtensions

      def extend_with(*params)
        scope = params.shift
        case scope.class.name
        when "Symbol" # model's scope
          # In DataMapper case this is just a method
          self.send(scope, *params)
        when "String" # SQL query or SQL query with params (e.g. ["created_at < ?", 1.day.ago])
          raise NotImplementedError.new("This method is unsupported, as DM doen't allow to extend relations with SQL")
        when "Array"
          self.extend_with(*scope)
        when "Hash"  # conditions hash
          self.all(scope)
        when "ActiveSupport::HashWithIndifferentAccess" # conditions hash
          self.all(scope)
        when "Proc"   # receives a relation, must return a relation
          scope.call(self)
        else
          raise ArgumentError, "Wrong parameter type for ActiveRecord::Relation#extend_with"
        end
      end

      # Non-destructively extends itself whith a hash of double-underscore'd conditions,
      # where the last part "__" is MetaWhere operator (which is required), e.g.:
      #     {:role__name__like => "%admin"}
      def extend_with_netzke_conditions(cond)
        cond.each_pair.inject(self) do |r, (k,v)|
          assoc, method, *operator = k.to_s.split("__")
          operator.empty? ? r.where(assoc.to_sym.send(method) => v) : r.where(assoc.to_sym => {method.to_sym.send(operator.last) => v}).joins(assoc.to_sym)
        end
      end

    end
  end
end
