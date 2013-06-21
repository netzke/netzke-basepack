module Netzke
  module Basepack
    class Grid < Netzke::Base
      # Implements Grid server-side operations. Used by the Endpoints module.
      module Services
        # Implementation for the "server_read" endpoint
        def read(params = {})
          {}.tap do |res|
            records = get_records(params)
            res[:data] = records.map{|r| data_adapter.record_to_array(r, final_columns(:with_meta => true))}
            res[:total] = count_records(params)  if config[:enable_pagination]
          end
        end

        # Returns hash with results per client (temporary) id, e.g.:
        #
        #   {
        #     1: {errors: [], record: {title: 'New title'}},
        #     2: {errors: ["Title must be present"], record: nil}
        #   }
        def create(data)
          data.inject({}) do |out, attrs|
            id = attrs.delete('internal_id')
            record = data_adapter.new_record
            out.merge(id => update_record(record, attrs))
          end
        end

        # Receives an array of attribute hashes, e.g.:
        #
        #   [{"id": 1, title: "New title"}, {"id": 2, title: ""}]
        #
        # Returns hash with results per id, e.g.:
        #
        #   {
        #     1: {errors: [], record: {title: 'New title'}},
        #     2: {errors: ["Title must be present"], record: nil}
        #   }
        def update(data)
          data.inject({}) do |out, attrs|
            id = attrs.delete(data_adapter.primary_key)
            record = data_adapter.find_record(id, scope: config.scope)
            record.nil? ? out.merge(id => {error: "Not allowed to edit record #{id}"}) : out.merge(id => update_record(record, attrs))
          end
        end

        # Destroys records by ids
        # Returns [destroyed_ids, errors]
        def destroy(ids)
          destroyed_ids = []
          errors = []
          ids.each {|id|
            record = data_adapter.find_record(id, scope: config[:scope])
            next if record.nil?

            if record.destroy
              destroyed_ids << id
            else
              record.errors.to_a.each do |msg|
                errors << msg
              end
            end
          }
          [destroyed_ids, errors]
        end

        # Returns an array of records.
        def get_records(params)
          params[:filters] = normalize_filters(params[:filters]) if params[:filters]
          params[:query] = normalize_query(params[:query]) if params[:query].present?
          if config[:enable_pagination]
            params[:limit] = config[:rows_per_page] 
          else
            params.delete(:limit)
          end
          params[:scope] = config[:scope] # note, params[:scope] becomes ActiveSupport::HashWithIndifferentAccess

          data_adapter.get_records(params, final_columns)
        end

        def count_records(params)
          params[:scope] = config[:scope] # note, params[:scope] becomes ActiveSupport::HashWithIndifferentAccess

          data_adapter.count_records(params, final_columns)
        end

        # Override this method to react on each operation that caused changing of data
        def on_data_changed
        end

      protected

        def normalize_filters(filters)
          filters.map do |f|
            { attr: f["field"], value: f["value"], operator: f["comparison"] }.tap do |norm|

              # Ext JS filters send us date in the American format
              if f["type"] == "date"
                norm[:value].match(/^(\d\d)\/(\d\d)\/(\d\d\d\d)$/)
                norm[:value] = "#{$3}-#{$1}-#{$2}"
              end

              if filter_with = final_columns_hash[norm[:attr].to_sym][:filter_with]
                norm[:proc] = filter_with
              end

              norm[:operator] = "contains" if f["type"] == "string"
            end
          end
        end

        def normalize_query(or_query)
          or_query.each do |and_query|
            and_query.each do |q|
              column_config = final_columns_hash[q[:attr].to_sym] || {}
              if filter_with = column_config[:filter_with]
                q[:proc] = filter_with
              end
            end
          end
        end

        def update_record(record, attrs)
          # merge with strong default attirbutes
          attrs.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]

          attrs.each_pair do |k,v|
            data_adapter.set_record_value_for_attribute(record, final_columns_hash[k.to_sym].nil? ? {:name => k} : final_columns_hash[k.to_sym], v, config.role || :default)
          end

          if record.save
            {record: data_adapter.record_to_array(record, final_columns(:with_meta => true))}
          else
            {error: record.errors.to_a}
          end
        end

      end
    end
  end
end
