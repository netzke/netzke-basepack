module Netzke
  module Basepack
    class Grid < Netzke::Base
      module Endpoints
        extend ActiveSupport::Concern

        included do
          endpoint :server_read do |data, this|
            attempt_operation(:read, data, this)
          end

          endpoint :server_create do |data, this|
            attempt_operation(:create, data, this)
          end

          endpoint :server_update do |data, this|
            attempt_operation(:update, data, this)
          end

          endpoint :server_delete do |ids, this|
            if !config[:prohibit_delete]
              destroyed_ids, errors = destroy(ids)

              feedback = errors
              if destroyed_ids.present?
                feedback << I18n.t('netzke.basepack.grid.deleted_n_records', :n => destroyed_ids.size)
                on_data_changed
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

          # Process the submit of multi-editing form ourselves
          # TODO: refactor to let the form handle the validations
          endpoint :multi_edit_window__multi_edit_form__netzke_submit do |params, this|
            ids = ActiveSupport::JSON.decode(params.delete(:ids))
            data = ids.collect{ |id| ActiveSupport::JSON.decode(params[:data]).merge("id" => id) }

            data.map!{|el| el.delete_if{ |k,v| v.is_a?(String) && (v.blank? || v == 'null') }} # only interested in set values

            res = attempt_operation(:update, data, this)

            errors = []
            res.each do |id, out|
              errors << out[:error] if out[:error]
            end

            if errors.empty?
              on_data_changed
              this.netzke_set_result("ok")
              this.on_submit_success
            end

            this.netzke_feedback(errors)
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

        # Operations:
        #   create, read, update, delete
        def attempt_operation(op, data, this)
          if !config["prohibit_#{op}"]
            res = send(op, data)
            this.netzke_set_result res
            res
          else
            this.netzke_feedback I18n.t("netzke.basepack.grid.cannot_#{op}")
          end
        end

      protected

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
      end
    end
  end
end
