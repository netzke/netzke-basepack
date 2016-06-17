module Netzke
  module Tree
    module Endpoints
      extend ActiveSupport::Concern

      included do
        endpoint :add_window__add_form__submit do |params|
          data = ActiveSupport::JSON.decode(params[:data])
          # FIXME: Commenting this out temporarily for SeeItsendIt
          # Review this quickly as this patch shouldn't be part of pull request
          #data["parent_id"] = params["parent_id"] unless params.keys.select{|k| k.include? 'parent__'}
          client.merge!(component_instance(:add_window).
                      component_instance(:add_form).
                      submit(data, client))
          on_data_changed if client.netzke_set_form_values.present?
          client.delete(:netzke_set_form_values)
        end

        endpoint :update_node_state do |params|
          node = model_adapter.find_record(params[:id])
          if node.respond_to?(:expanded)
            node.expanded = params[:expanded]
            model_adapter.save_record(node)
          end
        end

        endpoint :update_parent_id do |records|
          records.each do |record|
            r = model_adapter.find_record(record[:id])
            update_record(r, record)
          end
        end
      end
    end
  end
end
