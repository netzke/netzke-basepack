module Netzke
  module Basepack
    class Grid < Netzke::Base
      # Implements Grid server-side operations. Used by the Endpoints module.
      module Services
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

        # Implementation for the "get_data" endpoint
        def get_data(*args)
          params = args.first || {} # params are optional!
          if !config[:prohibit_read]
            {}.tap do |res|
              records = get_records(params)
              res[:data] = records.map{|r| data_adapter.record_to_array(r, final_columns(:with_meta => true))}
              res[:total] = count_records(params)  if config[:enable_pagination]
            end
          else
            flash :error => "You don't have permissions to read data"
            { :netzke_feedback => @flash }
          end
        end

        # Returns an array of records.
        def get_records(params)
          params[:limit] = config[:rows_per_page] if config[:enable_pagination]
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

        # Given an index of a column among enabled (non-excluded) columns, provides the index (position) in the table
        def normalize_index(index)
          norm_index = 0
          index.times do
            while true do
              norm_index += 1
              break unless final_columns[norm_index][:included] == false
            end
          end
          norm_index
        end

        # Params:
        # <tt>:operation</tt>: :update or :create
        def process_data(data, operation)
          success = true
          mod_records = {}
          if !config[:"prohibit_#{operation}"]
            modified_records = 0
            data.each do |record_hash|
              id = record_hash.delete('id')
              record = operation == :create ? data_adapter.new_record : data_adapter.find_record(id)
              success = true

              # merge with strong default attirbutes
              record_hash.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]

              record_hash.each_pair do |k,v|
                data_adapter.set_record_value_for_attribute(record, final_columns_hash[k.to_sym].nil? ? {:name => k} : final_columns_hash[k.to_sym], v, config.role || :default)
              end

              # try to save
              mod_records[id] = data_adapter.record_to_array(record, final_columns(:with_meta => true)) if success && record.save

              # flash eventual errors
              if !record.errors.empty?
                success = false
                record.errors.to_a.each do |msg|
                  flash :error => msg
                end
              end
            end
          else
            success = false
            flash :error => "You don't have permissions to #{operation} data"
          end
          mod_records
        end
      end
    end
  end
end
