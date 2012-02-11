module Netzke
  module Sequel
    module RelationExtensions
      def self.included receiver
        receiver.class_eval do
          def_dataset_method :extend_with do |*params|
            scope = params.shift
            case scope.class.name
            when "Symbol" # model's scope
              self.send(scope, *params)
            when "String" # SQL query or SQL query with params (e.g. ["created_at < ?", 1.day.ago])
              params.empty? ? self.where(scope) : self.where([scope, *params])
            when "Array"
              self.extend_with(*scope)
            when "Hash"  # conditions hash
              self.where(scope)
            when "ActiveSupport::HashWithIndifferentAccess" # conditions hash
              self.where(scope)
            when "Proc"   # receives a relation, must return a relation
              scope.call(self)
            else
              raise ArgumentError, "Wrong parameter type for ActiveRecord::Relation#extend_with"
            end
          end

          # Non-destructively extends itself whith a hash of double-underscore'd conditions,
          # where the last part "__" is MetaWhere operator (which is required), e.g.:
          #     {:role__name__like => "%admin"}

          def_dataset_method :extend_with_netzke_conditions do |cond|
            cond.each_pair.inject(self) do |r, (k,v)|
              assoc, method, *operator = k.to_s.split("__")
              operator.empty? ? r.where(assoc.to_sym.send(method) => v) : r.where(assoc.to_sym => {method.to_sym.send(operator.last) => v}).joins(assoc.to_sym)
            end
          end
        end
      end
    end
  end
end
