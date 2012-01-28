module Netzke::Basepack::DataAdapters
  class DataMapperAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= DataMapper::Resource
    end

    def get_records(params, columns=[])
      search_query = @model_class

      # used for specifying models to join (for ordering and column selection)
      links = []
      # join association models into query if they are specified in query
      # NOTE: AFAIK, in DataMapper there is no possibility to specify columns to fetch from the joined table, and a second ID IN query will be done after the join query, if you specify i.e. author__first_name columnon :book grid
      columns.each do |column|
        if column[:name].index('__')
          assoc, _ = column[:name].split('__')
          link = @model_class.relationships[assoc.to_sym].inverse
          links << link unless links.include? link
        end
      end

      # apply filter
      search_query = apply_column_filters search_query, params[:filter] if params[:filter]
      query_options = {}

      # apply sorting
      if params[:sort] && sort_params = params[:sort]
        order = []
        sort_params.each do |sort_param|
          assoc, method = sort_param["property"].split("__")
          dir = sort_param["direction"].downcase

          # if a sorting scope is set, call the scope with the given direction
          column = columns.detect { |c| c[:name] == sort_param["property"] }
          if column.try(:'has_key?', :sorting_scope)
            search_query = search_query.send(column[:sorting_scope].to_sym, dir.to_sym)
          else
            if method
              order << @model_class.send(assoc).send(method).send(dir)
              link = @model_class.relationships[assoc.to_sym].inverse
              links << link unless links.include? link
            else
              order << assoc.to_sym.send(dir)
            end
          end
        end
        query_options[:order] = order unless order.empty?
        query_options[:links] = links unless links.empty?
      end

      # apply paging
      query_options[:limit]=params[:limit] if params[:limit]
      query_options[:offset]=params[:start] if params[:start]

      # apply scope
      search_query = search_query.extend_with(params[:scope]) if params[:scope]

      search_query.all(query_options)
    end

    def count_records(params, columns=[])
      # delete pagig related params, as this would break the query
      params=params.reject { |k, v|
        [:start, :limit, :page].include? k.to_sym
      }
      # this will NOT do a SELECT *, but a SELECT COUNT(*)
      get_records(params, columns).count
    end

    def map_type type
      @typemap ||= {
        DataMapper::Property::Integer => :integer,
        DataMapper::Property::Serial => :integer,
        DataMapper::Property::Boolean => :boolean,
        DataMapper::Property::Date => :date,
        DataMapper::Property::DateTime => :datetime,
        DataMapper::Property::Time => :time,
        DataMapper::Property::String => :string,
        DataMapper::Property::Text => :text
      }
      @typemap[type]
    end

    def get_assoc_property_type assoc_name, prop_name
      assoc = @model_class.send(assoc_name)
      # prop_name could be a virtual column, check it first, return nil in this case
      assoc.respond_to?(prop_name) ? map_type(assoc.send(prop_name).property.class) : nil
    end

    def column_virtual? c
      assoc_name, assoc_method = c[:name].split '__'
      if assoc_method
        column_names=@model_class.send(assoc_name).model.column_names
        column_name=assoc_method
      else
        column_names=@model_class.column_names
        column_name=c[:name]
      end
      !column_names.include? column_name
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
          relation = @model_class.send(assoc_name).model

          relation = relation.extend_with(method_options[:scope]) if method_options[:scope]

          if klass_for(assoc_name).column_names.include?(assoc_method)
            # apply query
            relation = relation.all(assoc_method.to_sym.send(:like) => "%#{query}%") if query.present?
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
      @model_class.relationships[assoc_name].child_key.first.name.to_s
    end

    # Returns the model class for association columns
    def klass_for assoc_name
      @model_class.send(assoc_name).model
    end

    def destroy(ids)
      @model_class.all(:id => ids).destroy
    end

    def find_record(id)
      @model_class.get(id)
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      @model_class.relationships.inject({}) do |foreign_keys, rel|
        if rel.kind_of? DataMapper::Associations::ManyToOne::Relationship
          foreign_keys[rel.child_key.first.name]=rel.parent_model.to_s.downcase.to_sym
          foreign_keys
        end
      end || {}
    end

    def move_records(params)
      @model_class.all(:id => params[:ids]).each_with_index do |item, index|
        item.move(:to => params[:new_index] + index)
      end
    end

    # Needed for seed and tests
    def last
      @model_class.last
    end

    def destroy_all
      @model_class.all.destroy
    end

    private

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
    # This will result in:
    #      Clazz.get(:id => 10, :food_name.like => "%pizza")
    def apply_column_filters(relation, column_filter)
      # these are still JSON-encoded due to the migration to Ext.direct
      column_filter=JSON.parse(column_filter)

      conditions = {}
      column_filter.each do |v|
        assoc, method = v["field"].split('__')
        if method
          query_path = relation.send(assoc).send(method) # Book.athor.last_name.like
        else
          query_path = assoc.to_sym # :last_name.like
        end

        value = v["value"]
        type = v["type"]
        case v["comparison"]
        when "lt"
          query_path=query_path.lt if ["date","numeric"].include? type
        when "gt"
          query_path=query_path.gt if ["date","numeric"].include? type
        else
          query_path=query_path.like if type == "string"
        end

        case type
        when "string"
          conditions[query_path]="%#{value}%"
        when "date"
          # convert value to the DB date
          value.match /(\d\d)\/(\d\d)\/(\d\d\d\d)/
          conditions[query_path]="#{$3}-#{$1}-#{$2}"
        else
          conditions[query_path]=value
        end
      end
      relation.all conditions
    end

  end

end
