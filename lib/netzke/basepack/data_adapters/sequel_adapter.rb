module Netzke::Basepack::DataAdapters
  class SequelAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= Sequel::Model
    end

    def get_records(params, columns=[])
      get_dataset(params, columns).all
    end

    def count_records(params)
      get_dataset(params, [], true).count
    end

    def map_type type
      type
    end

    def get_assoc_property_type assoc_name, prop_name
    end

    # like get_assoc_property_type but for non-association columns
    # TODO
    def get_property_type column
    end

    def column_virtual? c
      assoc, method = c[:name].split '__'
      if method
        !@model_class.association_reflection(assoc.to_sym)[:class_name].constantize.columns.include? method.to_sym
      else
        !@model_class.columns.include? assoc.to_sym
      end
    end

    # Returns options for comboboxes in grids/forms
    # TODO
    def combobox_options_for_column(column, method_options = {})
    end

    def foreign_key_for assoc_name
      @model_class.association_reflection(assoc_name.to_sym)[:key].to_s
    end

    # Returns the model class for an association
    def klass_for assoc_name
      @model_class.association_reflection(assoc_name.to_sym)[:class_name].constantize
    end

    def destroy(ids)
      @model_class.where(id: ids).destroy
    end

    def find_record(id)
      @model_class[id]
    end

    # Build a hash of foreign keys and the associated model
    # TODO
    def hash_fk_model
    end

    # TODO: is this possible with Sequel?
    def move_records(params)
    end

    # Needed for seed and tests
    # TODO
    def last
    end

    # TODO
    def destroy_all
    end

    private
    def get_dataset params, columns, for_count=false
      dataset = @model_class

      graphed=[]

      # Parses and applies grid column filters
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

      if params[:filter]
        # these are still JSON-encoded due to the migration to Ext.direct
        column_filter=JSON.parse(params[:filter])

        column_filter.each do |v|
          field = v["field"]
          assoc, method = field.split('__')
          if method
            # when filtering on association's columns, we need to graph for LEFT OUTER JOIN
            dataset = dataset.eager_graph assoc.to_sym unless graphed.include? assoc.to_sym
            graphed << assoc.to_sym
          end

          value = v["value"]
          type = v["type"]
          op = v["comparison"]

          if type == "string"
            # strings are always LIKEd (case-insensitive)
            dataset = dataset.filter field.to_sym.ilike("%#{value}%")
          else
            if type == "date"
              # convert value to the DB date
              value.match /(\d\d)\/(\d\d)\/(\d\d\d\d)/
              value = "#{$3}-#{$1}-#{$2}"
            end
            # if it's NOT an association column, we need to qualify column name with model's table_name
            qualified_column_name = method ? field.to_sym : field.to_sym.qualify(@model_class.table_name)
            case op
            when 'eq'
              dataset = dataset.filter qualified_column_name => value
            when 'lt'
              dataset = dataset.filter ":column < #{value}", :column => qualified_column_name
            when 'gt'
              dataset = dataset.filter ":column > #{value}", :column => qualified_column_name
            end
          end
        end
      end
      # skip sorting, eager joining and paging if dataset is used for count
      unless for_count
        if params[:sort] && sort_params = params[:sort]
          sort_params.each do |sort_param|
            assoc, method = sort_param["property"].split("__")
            dir = sort_param["direction"].downcase

            # if a sorting scope is set, call the scope with the given direction
            column = columns.detect { |c| c[:name] == sort_param["property"] }
            if column.try(:'has_key?', :sorting_scope)
              dataset = dataset.send(column[:sorting_scope].to_sym, dir.to_sym)
            else
              if method # sorting on associations column
                # graph the association for LEFT OUTER JOIN
                dataset = dataset.eager_graph(assoc.to_sym) unless graphed.include? assoc.to_sym
                graphed << assoc.to_sym
              end
              # coincidentally, netzkes convention of specifying association's attributes
              # i.e. "author__name" on Book matches sequel's convention
              # so we can just pass symbolized property here
              dataset = dataset.order(sort_param["property"].to_sym)
            end
          end
        end

        # eager load the associations indicated by columns,
        # but only if we didn't eager_graph them before (for ordering/filtering)
        # because this saves a ID IN query
        columns.each do |column|
          if column[:name].index('__')
            assoc, _ = column[:name].split('__')
            dataset = dataset.eager(assoc.to_sym) unless graphed.include? assoc.to_sym
          end
        end

        # apply paging
        if params[:limit]
          if params[:start]
            dataset = dataset.limit params[:limit], params[:start]
          else
            dataset = dataset.limit params[:limit]
          end
        end
      end

      # apply scope
      dataset = dataset.extend_with(params[:scope]) if params[:scope]
      dataset
    end
  end

end
