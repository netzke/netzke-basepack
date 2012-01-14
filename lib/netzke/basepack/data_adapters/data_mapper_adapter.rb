module Netzke::Basepack::DataAdapters
  class DataMapperAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= DataMapper::Resource
    end

    # WIP. Introduce filtering, scopes, pagination, etc
    def get_records(params, columns)
      search_query = @model_class
      query = {}

      if params[:sort] && sort_params = params[:sort]
        order = []

        sort_params.each do |sort_param|
          assoc, method = sort_param["property"].split("__")
          dir = sort_params["direction"].downcase

          # TODO add association sorting
          order << assoc.to_sym.send(dir)
        end

        search_query = search_query.all(:order => order)
      end

      search_query = search_query.all(:conditions => params[:scope]) if params[:scope]

      if params[:limit]
        query[:limit]=params[:limit]
        query[:start]=params[:start]
      end
      search_query.all(query)
    end

    def count_records(params,columns)
      @model_clas.count()
    end

    def dm_type_map
      {
        DataMapper::Property::Integer => :integer,
        DataMapper::Property::Serial => :integer,
        DataMapper::Property::Boolean => :boolean,
        DataMapper::Property::Date => :date,
        DataMapper::Property::DateTime => :datetime,
        DataMapper::Property::Time => :datetime,
        DataMapper::Property::Json => :json,
        DataMapper::Property::String => :string,
        DataMapper::Property::Text => :text
      }
    end

    def get_assoc_property_type model, assoc_name, prop_name
      assoc = model.send(assoc_name)
      # prop_name could be a virtual column, check it first
      assoc.respond_to?(prop_name) ? dm_type_map[assoc.send(prop_name)] : nil
    end

    def destroy(ids)
      @model_class.destroy(:id => ids)
    end

    def find_record(id)
      @model_class.get(id)
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
  end
end
