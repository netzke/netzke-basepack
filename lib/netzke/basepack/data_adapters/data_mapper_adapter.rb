require 'will_paginate/data_mapper'

module Netzke::Basepack::DataAdapters
  class DataMapperAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= DataMapper::Resource
    end

    # WIP. Introduce filtering, scopes, pagination, etc
    def get_records(params, columns, with_pagination = true)
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

      if with_pagination
        page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
        query[:per_page]=params[:limit] if params[:limit]
        query[:page]=page
        search_query.paginate(query)
      else
        search_query.all(query)
      end
    end

    def last
      @model_class.last
    end

    def destroy_all
      @model_class.all.destroy
    end

    def destroy(ids)
      @model_class.destroy(:id => ids)
    end

    def move_records(params)
      @model_class.all(:id => params[:ids]).each_with_index do |item, index|
        item.move(:to => params[:new_index] + index)
      end
    end
  end
end
