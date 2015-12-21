module Netzke
  module Basepack
    class Tree < Netzke::Base
      module Endpoints
        extend ActiveSupport::Concern

        included do
          endpoint :add_window__add_form__submit do |params|
            data = ActiveSupport::JSON.decode(params[:data])
            data["parent_id"] = params["parent_id"]
            client.merge!(component_instance(:add_window).
                        component_instance(:add_form).
                        submit(data, client))
            on_data_changed if client.set_form_values.present?
            client.delete(:set_form_values)
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
end
