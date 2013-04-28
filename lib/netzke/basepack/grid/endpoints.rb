module Netzke
  module Basepack
    class Grid < Netzke::Base
      module Endpoints
        extend ActiveSupport::Concern

        included do
          endpoint :get_data do |params, this|
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
              ids = ActiveSupport::JSON.decode(params[:records])
              destroyed_ids, errors = destroy(ids)

              feedback = errors
              if destroyed_ids.present?
                feedback << I18n.t('netzke.basepack.grid.deleted_n_records', :n => destroyed_ids.size)
                on_data_changed
                this.load_store_data(get_data)
              end
              this.netzke_feedback(feedback)
            else
              this.netzke_feedback I18n.t('netzke.basepack.grid.cannot_delete')
            end
          end

          endpoint :resize_column do |params, this|
            raise "Called resize_column endpoint while not configured to do so" if !config[:persistence]

            current_columns_order = state[:columns_order] || initial_columns_order
            current_columns_order[normalize_index(params[:index].to_i)][:width] = params[:size].to_i
            state[:columns_order] = current_columns_order
          end

          endpoint :move_column do |params, this|
            raise "Called move_column endpoint while not configured to do so" if !config[:persistence]

            remove_from = normalize_index(params[:old_index].to_i)
            insert_to = normalize_index(params[:new_index].to_i)

            current_columns_order = state[:columns_order] || initial_columns_order

            column_to_move = current_columns_order.delete_at(remove_from)
            current_columns_order.insert(insert_to, column_to_move)

            state[:columns_order] = current_columns_order
          end

          endpoint :hide_column do |params, this|
            raise "Called hide_column endpoint while not configured to do so" if !config[:persistence]
            current_columns_order = state[:columns_order] || initial_columns_order
            current_columns_order[normalize_index(params[:index].to_i)][:hidden] = params[:hidden]
            state[:columns_order] = current_columns_order
          end

          # Returns options for a combobox
          # params receive:
          # +attr+ - column's name
          # +query+ - what's typed-in in the combobox
          # +id+ - selected record id
          endpoint :get_combobox_options do |params, this|
            column = final_columns.detect{ |c| c[:name] == params[:attr] }
            this.data = data_adapter.combo_data(column, params[:query])
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

          # TODO: functionality of the following 2 endpoints could probably be improved by subclassing Basepack::Form as a dedicated form for adding/editing records in a grid.
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
              this.netzke_set_result("ok")
              this.on_submit_success
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
      end
    end
  end
end
