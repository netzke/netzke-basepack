module Netzke
  module Grid
    module Endpoints
      extend ActiveSupport::Concern

      included do
        endpoint :read do |data|
          attempt_operation(:read, data, client)
        end

        endpoint :create do |data|
          attempt_operation(:create, data, client)
        end

        endpoint :update do |data|
          attempt_operation(:update, data, client)
        end

        endpoint :destroy do |data|
          attempt_operation(:destroy, data, client)
        end

        endpoint :save_columns do |cols|
          state[:columns_order] = cols
        end

        # Returns options for a combobox
        # params receive:
        # +attr+ - column's name
        # +query+ - what's typed-in in the combobox
        # +id+ - selected record id
        endpoint :get_combobox_options do |params|
          column = non_meta_columns.detect{ |c| c[:name] == params[:attr] }
          client.data = model_adapter.combo_data(column, params[:query])
        end

        endpoint :move_rows do |params|
          model_adapter.move_records(params)
        end

        # Process the submit of multi-editing form ourselves
        # TODO: refactor to let the form handle the validations
        endpoint :multi_edit_window__multi_edit_form__submit do |params|
          ids = ActiveSupport::JSON.decode(params.delete(:ids))
          data = ids.collect{ |id| ActiveSupport::JSON.decode(params[:data]).merge("id" => id) }

          data.map!{|el| el.delete_if{ |k,v| v.is_a?(String) && v.blank? }} # only interested in set values

          res = attempt_operation(:update, data, client)

          errors = []
          res.each do |id, out|
            errors << out[:error] if out[:error]
          end

          if errors.empty?
            on_data_changed
            client.handle_submit_success
            "ok"
          else
            client.netzke_feedback(errors)
            "failure"
          end
        end

        # The following two look a bit hackish, but serve to invoke on_data_changed when a form gets successfully
        # submitted
        endpoint :add_window__add_form__submit do |params|
          client.merge!(component_instance(:add_window).
                      component_instance(:add_form).
                      invoke_endpoint(:submit, [params]))
          on_data_changed if client.netzke_set_form_values.present?
          client.delete(:netzke_set_form_values)
        end

        endpoint :edit_window__edit_form__submit do |params|
          client.merge!(component_instance(:edit_window).
                      component_instance(:edit_form).
                      invoke_endpoint(:submit, [params]))
          on_data_changed if client.netzke_set_form_values.present?
          client.delete(:netzke_set_form_values)
        end
      end

      # Operations:
      #   create, read, update, delete
      def attempt_operation(op, data, client)
        # if data is ActionController::Parameters and a scope is in the component config
        # then ran this in an ActiveModel::ForbiddenAttributesError (rails 4 strong parameters)
        # solution: in this case convert ActionController::Parameters to a Hash
        if data.is_a?ActionController::Parameters
          dataHash = {}
          data.each do |k,v|
            #preserve keys as symbol
            dataHash[k.to_sym] = v
          end
          data = dataHash
        end
        if !config["prohibit_#{op}"]
          send(op, data)
        else
          client.netzke_feedback I18n.t("netzke.basepack.grid.cannot_#{op}")
          { data: [], total: 0 }
        end
      end
    end
  end
end
