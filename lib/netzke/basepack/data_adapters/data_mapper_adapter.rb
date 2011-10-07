module Netzke::Basepack::DataAdapters
  class DataMapperAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= DataMapper::Resource
    end

    # WIP. Introduce filtering, scopes, pagination, etc
    def get_records(params, columns)
      @model_class.all
    end
  end
end