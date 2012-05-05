module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      module Services
        extend ActiveSupport::Concern

        included do

          endpoint :get_data do |params, this|
            # not a usual Netzke endpoint, as it's being used by the Ext.data.DirectStore
            this.merge! get_data(params)
          end

          endpoint :post_data do |params, this|
            mod_records = {}
            [:create, :update].each do |operation|
              data = ActiveSupport::JSON.decode(params["#{operation}d_records"]) if params["#{operation}d_records"]
              if !data.nil? && !data.empty? # data may be nil for one of the operations
                mod_records[operation] = process_data(data, operation)
                mod_records[operation] = nil if mod_records[operation].empty?
              end
            end

            on_data_changed

            this.update_new_records mod_records[:create]
            this.update_mod_records mod_records[:update] if mod_records[:update]
            this.netzke_feedback @flash
          end

          endpoint :delete_data do |params, this|
            if !config[:prohibit_delete]
              record_ids = ActiveSupport::JSON.decode(params[:records])
              data_adapter.destroy(record_ids)
              on_data_changed
              this.netzke_feedback I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size)
              this.load_store_data get_data
            else
              this.netzke_feedback I18n.t('netzke.basepack.grid_panel.cannot_delete')
            end
          end

          endpoint :resize_column do |params, this|
            raise "Called resize_column endpoint while not configured to do so" if !config[:persistence]
            current_columns_order = state[:columns_order] || initial_columns_order
            current_columns_order[normalize_index(params[:index].to_i)][:width] = params[:size].to_i
            update_state(:columns_order, current_columns_order)
          end

          endpoint :move_column do |params, this|
            raise "Called move_column endpoint while not configured to do so" if !config[:persistence]
            remove_from = normalize_index(params[:old_index].to_i)
            insert_to = normalize_index(params[:new_index].to_i)

            current_columns_order = state[:columns_order] || initial_columns_order

            column_to_move = current_columns_order.delete_at(remove_from)
            current_columns_order.insert(insert_to, column_to_move)

            update_state(:columns_order, current_columns_order)
          end

          endpoint :hide_column do |params, this|
            raise "Called hide_column endpoint while not configured to do so" if !config[:persistence]
            current_columns_order = state[:columns_order] || initial_columns_order
            current_columns_order[normalize_index(params[:index].to_i)][:hidden] = params[:hidden]
            update_state(:columns_order, current_columns_order)
          end

          # Returns choices for a column
          endpoint :get_combobox_options do |params, this|
            query = params[:query]

            column = final_columns.detect{ |c| c[:name] == params[:column] }
            scope = column.to_options[:scope] || column.to_options[:editor].try(:fetch, :scope, nil)
            query = params[:query]

            this[:data] = combobox_options_for_column(column, :query => query, :scope => scope, :record_id => params[:id])
          end

          endpoint :move_rows do |params, this|
            data_adapter.move_records(params)
          end

          # When providing the edit_form component, fill in the form with the requested record
          endpoint :deliver_component do |params, this|
            if params[:name] == 'edit_window'
              components[:edit_window].form_config.record_id = params[:record_id].to_i
            end

            super(params, this)
          end

          # Process the submit of multi-editing form ourselves
          endpoint :multi_edit_window__multi_edit_form__netzke_submit do |params, this|
            ids = ActiveSupport::JSON.decode(params.delete(:ids))
            data = ids.collect{ |id| ActiveSupport::JSON.decode(params[:data]).merge("id" => id) }

            data.map!{|el| el.delete_if{ |k,v| v.is_a?(String) && v.blank? }} # only interested in set values

            mod_records_count = process_data(data, :update).count

            # remove duplicated flash messages
            @flash = @flash.inject([]){ |r,hsh| r.include?(hsh) ? r : r.push(hsh) }

            if mod_records_count > 0
              on_data_changed
              this.set_result("ok")
            end

            this.netzke_feedback(@flash)
          end

          # The following two look a bit hackish, but serve to invoke on_data_changed when a form gets successfully submitted
          endpoint :add_window__add_form__netzke_submit do |params, this|
            this.merge!(component_instance(:add_window__add_form).invoke_endpoint(:netzke_submit, params))
            on_data_changed if this.set_form_values.present?
            this.delete(:set_form_values)
          end

          endpoint :edit_window__edit_form__netzke_submit do |params, this|
            this.merge!(component_instance(:edit_window__edit_form).invoke_endpoint(:netzke_submit, params))
            on_data_changed if this.set_form_values.present?
            this.delete(:set_form_values)
          end
        end

        # Implementation for the "get_data" endpoint
        def get_data(*args)
          params = args.first || {} # params are optional!
          if !config[:prohibit_read]
            {}.tap do |res|
              records = get_records(params)
              res[:data] = records.map{|r| r.netzke_array(final_columns(:with_meta => true))}
              res[:total] = count_records(params)  if config[:enable_pagination]
            end
          else
            flash :error => "You don't have permissions to read data"
            { :netzke_feedback => @flash }
          end
        end

        protected

          # Returns an array of records.
          def get_records(params)

            # Restore params from component_session if requested
            if params[:with_last_params]
              params = component_session[:last_params]
            else
              # remember the last params
              component_session[:last_params] = params
            end

            params[:limit] = config[:rows_per_page] if config[:enable_pagination]
            params[:scope] = config[:scope] # note, params[:scope] becomes ActiveSupport::HashWithIndifferentAccess

            data_adapter.get_records(params, final_columns)
          end

          def count_records(params)
            # Restore params from component_session if requested
            if params[:with_last_params]
              params = component_session[:last_params]
            else
              # remember the last params
              component_session[:last_params] = params
            end

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
                  record.set_value_for_attribute(final_columns_hash[k.to_sym].nil? ? {:name => k} : final_columns_hash[k.to_sym], v, config.role || :default)
                end

                # try to save
                mod_records[id] = record.netzke_array(final_columns(:with_meta => true)) if success && record.save

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
