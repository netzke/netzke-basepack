require "active_record"

module Netzke::ActiveRecord
  # Provides extensions to all ActiveRecord-based classes
  module AssociationAttributes
    module ClassMethods
    end

    module InstanceMethods
      # Allow nested association access (assocs separated by "." or "__"), e.g.: proxy_service.asset__gui_folder__name
      # Example:
      #
      #   Book.first.genre__name = 'Fantasy'
      #
      # is the same as:
      #
      #   Book.first.genre = Genre.find_by_name('Fantasy')
      #
      # The result - easier forms and grids that handle nested models: simply specify column/field name as "genre__name".
      def method_missing_with_basepack(method, *args, &block)
        # if refering to a column, just pass it to the original method_missing
        return method_missing_without_basepack(method, *args, &block) if self.class.column_names.include?(method.to_s)

        split = method.to_s.split(/\.|__/)
        if split.size > 1
          if split.last =~ /=$/
            if split.size == 2
              # search for association and assign it to self
              assoc = self.class.reflect_on_association(split.first.to_sym)
              assoc_method = split.last.chop
              if assoc
                begin
                  assoc_instance = assoc.klass.send("find_by_#{assoc_method}", *args)
                rescue NoMethodError
                  assoc_instance = nil
                  logger.debug "!!! no find_by_#{assoc_method} method for class #{assoc.klass.name}\n"
                end
                if (assoc_instance)
                  self.send("#{split.first}=", assoc_instance)
                else
                  logger.debug "!!! Couldn't find association #{split.first} by #{assoc_method} '#{args.first}'"
                end
              else
                method_missing_without_basepack(method, *args, &block)
              end
            else
              method_missing_without_basepack(method, *args, &block)
            end
          else
            res = self
            split.each do |m|
              if res.respond_to?(m)
                res = res.send(m) unless res.nil?
              else
                res.nil? ? nil : method_missing_without_basepack(method, *args, &block)
              end
            end
            res
          end
        else
          method_missing_without_basepack(method, *args, &block)
        end
      end

      # Make respond_to? return true for association assignment method, like "genre__name="
      def respond_to_with_basepack?(method, include_private = false)
        split = method.to_s.split(/__/)
        if split.size > 1
          if split.last =~ /=$/
            if split.size == 2
              # search for association and assign it to self
              assoc = self.class.reflect_on_association(split.first.to_sym)
              assoc_method = split.last.chop
              if assoc
                assoc.klass.respond_to?("find_by_#{assoc_method}")
              else
                respond_to_without_basepack?(method, include_private)
              end
            else
              respond_to_without_basepack?(method, include_private)
            end
          else
            # self.respond_to?(split.first) ? self.send(split.first).respond_to?(split[1..-1].join("__")) : false
            respond_to_without_basepack?(method, include_private)
          end
        else
          respond_to_without_basepack?(method, include_private)
        end
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods

      receiver.send :include, InstanceMethods
      receiver.alias_method_chain :method_missing, :basepack
      receiver.alias_method_chain :respond_to?, :basepack
    end

  end
end

