module Netzke::Basepack::DataAdapters
  class ActiveRecordAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= ActiveRecord::Base
    end

    def get_records(params, columns=[])
      # build initial relation based on passed params
      relation = get_relation(params)

      # addressing the n+1 query problem
      columns.each do |c|
        assoc, method = c[:name].split('__')
        relation = relation.includes(assoc.to_sym) if method
      end

      # apply sorting if needed
      if params[:sort] && sort_params = params[:sort].first
        assoc, method = sort_params["property"].split('__')
        dir = sort_params["direction"].downcase

        # if a sorting scope is set, call the scope with the given direction
        column = columns.detect { |c| c[:name] == sort_params["property"] }
        if column.has_key?(:sorting_scope)
          relation = relation.send(column[:sorting_scope].to_sym, dir.to_sym)
        else
          relation = if method.nil?
            relation.order("#{assoc} #{dir}")
          else
            assoc = @model_class.reflect_on_association(assoc.to_sym)
            relation.joins(assoc.name).order("#{assoc.klass.table_name}.#{method} #{dir}")
          end
        end
      end

      page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
      if params[:limit]
        relation.offset(params[:start]).limit(params[:limit])
      else
        relation.all
      end
    end

    def count_records(params)
      # build initial relation based on passed params
      relation = get_relation(params)

      relation.count
    end

    def get_assoc_property_type assoc_name, prop_name
      if prop_name && assoc=@model_class.reflect_on_association(assoc_name)
        assoc_column = assoc.klass.columns_hash[prop_name.to_s]
        assoc_column.try(:type)
      end
    end

    def column_virtual? c
      assoc_name, asso = c[:name].split('__')
      assoc, assoc_method = assoc_and_assoc_method_for_attr(c[:name])

      if assoc
        return !assoc.klass.column_names.map(&:to_sym).include?(assoc_method.to_sym)
      else
        return !@model_class.column_names.map(&:to_sym).include?(c[:name].to_sym)
      end
    end

    # Returns options for comboboxes in grids/forms
    def combobox_options_for_column(column, method_options = {})
      query = method_options[:query]

      # First, check if we have options for this column defined in persistent storage
      options = column[:combobox_options] && column[:combobox_options].split("\n")
      if options
        query ? options.select{ |o| o.index(/^#{query}/) }.map{ |el| [el] } : options
      else
        assoc, assoc_method = assoc_and_assoc_method_for_attr(column[:name])

        if assoc
          # Options for an asssociation attribute

          relation = assoc.klass.scoped

          relation = relation.extend_with(method_options[:scope]) if method_options[:scope]

          if assoc.klass.column_names.include?(assoc_method)
            # apply query
            relation = relation.where(["#{assoc_method} like ?", "%#{query}%"]) if query.present?
            relation.all.map{ |r| [r.id, r.send(assoc_method)] }
          else
            relation.all.map{ |r| [r.id, r.send(assoc_method)] }.select{ |id,value| value =~ /^#{query}/ }
          end

        else
          # Options for a non-association attribute
          res=@model_class.netzke_combo_options_for(column[:name], method_options)

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

    def foreign_key_for assoc_name
      @model_class.reflect_on_association(assoc_name.to_sym).foreign_key
    end

    # Returns the model class for association columns
    def klass_for assoc_name
      @model_class.reflect_on_association(assoc_name.to_sym).klass
    end

    def destroy(ids)
      @model_class.destroy(ids)
    end

    def find_record(id)
      @model_class.find_all_by_id(id).first
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      foreign_keys = {}
      @model_class.reflect_on_all_associations(:belongs_to).map{ |r|
        foreign_keys[r.association_foreign_key.to_sym] = r.name
      }
      foreign_keys
    end

    def move_records(params)
      if defined?(ActsAsList) && @model_class.ancestors.include?(ActsAsList::InstanceMethods)
        ids = JSON.parse(params[:ids]).reverse
        ids.each_with_index do |id, i|
          r = @model_class.find(id)
          r.insert_at(params[:new_index].to_i + i + 1)
        end
        on_data_changed
      else
        raise RuntimeError, "Model class should implement 'acts_as_list' to support reordering records"
      end
    end

    # Returns association and association method for a column
    def assoc_and_assoc_method_for_attr(column_name)
      assoc_name, assoc_method = column_name.split('__')
      assoc = @model_class.reflect_on_association(assoc_name.to_sym) if assoc_method
      [assoc, assoc_method]
    end


    # An ActiveRecord::Relation instance encapsulating all the necessary conditions.
    def get_relation(params = {})
      @arel = @model_class.arel_table

      relation = @model_class.scoped

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

      relation = relation.extend_with(params[:scope]) if params[:scope]

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
          assoc = @model_class.reflect_on_association(assoc.to_sym)
          field = [assoc.klass.table_name, method].join('.').to_sym
        else
          field = assoc.to_sym
        end

        value = v["value"]

        op = operator_map[v['comparison']]

        case v["type"]
        when "string"
          res = res.where(["#{field} like ?", "%#{value}%"])
        when "date"
          # convert value to the DB date
          value.match /(\d\d)\/(\d\d)\/(\d\d\d\d)/
          res = res.where("#{field} #{op} ?", "#{$3}-#{$1}-#{$2}")
        when "numeric"
          res = res.where(["#{field} #{op} ?", value])
        else
          res = res.where(["#{field} = ?", value])
        end
      end

      res
    end

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
