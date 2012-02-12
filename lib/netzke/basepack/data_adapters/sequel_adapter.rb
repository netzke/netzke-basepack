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
      db_schema=class_for(assoc_name.to_sym).db_schema
      # return nil if prop_name not present in db schema (virtual column)
      db_schema[prop_name.to_sym] ? db_schema[prop_name.to_sym][:type] : nil
    end

    # like get_assoc_property_type but for non-association columns
    def get_property_type column
      @model_class.db_schema[column.to_sym][:type]
    end

    def column_virtual? c
      assoc, method = c[:name].split '__'
      if method
        class_for(assoc.to_sym).columns.include? method.to_sym
      else
        !@model_class.columns.include? assoc.to_sym
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
        assoc_name, assoc_method = column[:name].split '__'

        if assoc_name
          # Options for an asssociation attribute
          dataset = class_for(assoc_name)

          dataset = dataset.extend_with(method_options[:scope]) if method_options[:scope]

          if class_for(assoc_name).column_names.include?(assoc_method)
            # apply query
            dataset = dataset.where(assoc_method.to_sym.like("%#{query}%")) if query.present?
            dataset.all.map{ |r| [r.id, r.send(assoc_method)] }
          else
            dataset.all.map{ |r| [r.id, r.send(assoc_method)] }.select{ |id,value| value =~ /^#{query}/ }
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
      @model_class.association_reflection(assoc_name.to_sym)[:key].to_s
    end

    # Returns the model class for an association
    def class_for assoc_name
      @model_class.association_reflection(assoc_name.to_sym)[:class_name].constantize
    end

    def destroy(ids)
      @model_class.where(:id => ids).destroy
    end

    def find_record(id)
      @model_class[id]
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      @model_class.all_association_reflections.inject({}) do |res, assoc|
        res[assoc[:key]] = assoc[:class_name].constantize.model_name.underscore.to_sym
        res
      end
    end

    # TODO: is this possible with Sequel?
    def move_records(params)
    end

    # give the data adapter the opportunity the set special options for
    # saving
    def save_record(record)
      # don't raise an error on saving. basepack will evaluate record.errors
      # to get validation errors
      record.raise_on_save_failure = false
      record.save
    end

    # Needed for seed and tests
    def last
      @model_class.last
    end

    # Needed for seed and tests
    def destroy_all
      @model_class.destroy
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
      # need to symbolize_keys, because when the request is made from client-side (as opposed
      # to server-side on inital render), the scope's keys are given as string {"author_id" => 1}
      # If we give Sequel a filter like this, it will (correctly) do WHERE 'author_id' = 1 - note the quotes
      # making the database match the string author_id to 1 and to the column.
      dataset = dataset.extend_with(params[:scope].symbolize_keys) if params[:scope]
      dataset
    end
  end

end
