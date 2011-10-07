module Netzke
  module Basepack
    # This module is included into such data-driven components as GridPanel, FormPanel, PagingFormPanel, etc.
    module DataAccessor

      # Returns options for comboboxes in grids/forms
      def combobox_options_for_column(column, method_options = {})
        query = method_options[:query]

        # First, check if we have options for this column defined in persistent storage
        options = column[:combobox_options] && column[:combobox_options].split("\n")
        if options
          query ? options.select{ |o| o.index(/^#{query}/) }.map{ |el| [el] } : options
        else
          assoc, assoc_method = assoc_and_assoc_method_for_attr(column)

          if assoc
            # Options for an asssociation attribute

            relation = assoc.klass.scoped

            relation = relation.extend_with(method_options[:scope]) if method_options[:scope]

            if assoc.klass.column_names.include?(assoc_method)
              # apply query
              relation = relation.where(:"#{assoc_method}".like => "#{query}%") if query.present?
              relation.all.map{ |r| [r.id, r.send(assoc_method)] }
            else
              relation.all.map{ |r| [r.id, r.send(assoc_method)] }.select{ |id,value| value =~ /^#{query}/ }
            end

          else
            # Options for a non-association attribute
            res=data_class.netzke_combo_options_for(column[:name], method_options)

            # ensure it is an array-in-array, as Ext will fail otherwise
            raise RuntimeError, "netzke_combo_options_for should return an Array" unless res.kind_of? Array
            return [[]] if res.empty?

            unless res.first.kind_of? Array
              res=res.map do |v|
                [v]
              end
            end
            return res


          end
        end
      end

      # Normalize array of attributes
      # [:col1, "col2", {:name => :col3}] =>
      #   [{:name => "col1"}, {:name => "col2"}, {:name => "col3"}]
      def normalize_attrs(attrs)
        attrs.map{ |a| normalize_attr(a) }
      end

      # Normalize an attribute, e.g.:
      # :first_name =>
      #   {:name => "first_name"}
      def normalize_attr(a)
        a.is_a?(Symbol) || a.is_a?(String) ? {:name => a.to_s} : a.merge(:name => a[:name].to_s)
      end

      # Returns association and association method for a column
      def assoc_and_assoc_method_for_attr(c)
        assoc_name, assoc_method = c[:name].split('__')
        assoc = data_class.reflect_on_association(assoc_name.to_sym) if assoc_method
        [assoc, assoc_method]
      end

      def association_attr?(name)
        !!name.to_s.index("__")
      end

      # Model class
      def data_class
        @data_class ||= config[:model].is_a?(String) ? config[:model].constantize : config[:model]
      end

      # Data adapter responsible for all DB-related operations (WIP)
      def data_adapter
        @data_adapter ||= Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(data_class).new(data_class)
      end

      # whether a column is bound to the primary_key
      def primary_key_attr?(a)
        data_class && a[:name].to_s == data_class.primary_key
      end

      # Mark an attribute as "virtual" by default, when it doesn't reflect a model column, or a model column of an association
      def set_default_virtual(c)
        if c[:virtual].nil? # sometimes at maybe handy to mark a column as non-virtual forcefully
          assoc, assoc_method = assoc_and_assoc_method_for_attr(c)
          if assoc
            c[:virtual] = true if !assoc.klass.column_names.map(&:to_sym).include?(assoc_method.to_sym)
          else
            c[:virtual] = true if !data_class.column_names.map(&:to_sym).include?(c[:name].to_sym)
          end
        end
      end

      protected

        def predicates_for_and_conditions(conditions)
          return nil if conditions.empty?

          predicates = conditions.map do |q|
            value = q["value"]
            case q["operator"]
            when "contains"
              @arel[q["attr"]].matches "%#{value}%"
            else
              if value == false || value == true
                @arel[q["attr"]].eq(value ? 1 : 0)
              else
                @arel[q["attr"]].send(q["operator"], value)
              end
            end
          end

          # join them by AND
          predicates[1..-1].inject(predicates.first){ |r,p| r.and(p)  }
        end

    end
  end
end
