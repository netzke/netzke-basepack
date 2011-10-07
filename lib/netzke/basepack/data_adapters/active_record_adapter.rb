module Netzke::Basepack::DataAdapters
  class ActiveRecordAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= ActiveRecord::Base
    end

    def get_records(params, columns)
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

      # WIP: enable pagination
      # apply pagination if needed
      # if config[:enable_pagination]
      #   per_page = config[:rows_per_page]
      #   page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
      #   relation.paginate(:per_page => per_page, :page => page)
      # else
      #   relation.all
      # end

      page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
      relation.paginate(:per_page => params[:limit], :page => page)
    end

    private

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

  end
end