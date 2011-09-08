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
        @data_class ||= begin
          klass = constantize_class_name("Netzke::ModelExtensions::#{config[:model]}For#{short_component_class_name}") || original_data_class
        end
      end

      # Model class before model extensions are taken into account
      def original_data_class
        @original_data_class ||= begin
          ::ActiveSupport::Deprecation.warn("data_class_name option is deprecated. Use model instead", caller) if config[:data_class_name]
          model_name = config[:model] || config[:data_class_name]
          model_name && constantize_class_name(model_name)
        end
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

      # An ActiveRecord::Relation instance encapsulating all the necessary conditions.
      def get_relation(params = {})
        @arel = data_class.arel_table

        relation = data_class.scoped

        relation = apply_column_filters(relation, params[:filter]) if params[:filter]

        if params[:extra_conditions]
          extra_conditions = normalize_extra_conditions(ActiveSupport::JSON.decode(params[:extra_conditions]))
          relation = relation.extend_with_netzke_conditions(extra_conditions) if params[:extra_conditions]
        end

        query = params[:query] && ActiveSupport::JSON.decode(params[:query])

        if query.present?
          # array of arrays of conditions that should be joined by OR
          and_predicates = query.map do |conditions|
            predicates_for_and_conditions(conditions)
          end

          # join them by OR
          predicates = and_predicates[1..-1].inject(and_predicates.first){ |r,c| r.or(c) }
        end

        relation = relation.where(predicates)

        relation = relation.extend_with(config[:scope]) if config[:scope]

        relation
      end

      # Parses and applies grid column filters, calling consequent "where" methods on the passed relation.
      # Returns the updated relation.
      #
      # Example column grid data:
      #
      #     {"0" => {
      #       "data" => {
      #         "type" => "numeric",
      #         "comparison" => "gt",
      #         "value" => 10 },
      #       "field" => "id"
      #     },
      #     "1" => {
      #       "data" => {
      #         "type" => "string",
      #         "value" => "pizza"
      #       },
      #       "field" => "food_name"
      #     }}
      #
      # This will result in:
      #
      #      relation.where(["id > ?", 10]).where(["food_name like ?", "%pizza%"])
      def apply_column_filters(relation, column_filter)
        res = relation
        operator_map = {"lt" => "<", "gt" => ">", "eq" => "="}

        # these are still JSON-encoded due to the migration to Ext.direct
        column_filter=JSON.parse(column_filter)
        column_filter.each do |v|
          assoc, method = v["field"].split('__')
          if method
            assoc = data_class.reflect_on_association(assoc.to_sym)
            field = [assoc.klass.table_name, method].join('.').to_sym
          else
            field = assoc.to_sym
          end

          value = v["value"]

          op = operator_map[v['comparison']]

          case v["type"]
          when "string"
            res = res.where(["#{field} like ?", "%#{value}%"])
          when "numeric", "date"
            res = res.where(["#{field} #{op} ?", value])
          else
            res = res.where(["#{field} = ?", value])
          end
        end

        res
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
