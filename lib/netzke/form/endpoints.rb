module Netzke
  module Form
    module Endpoints
      extend ActiveSupport::Concern

      included do
        # Called when the form gets submitted (e.g. by pressing the Apply button)
        endpoint :submit do |params|
          data = ActiveSupport::JSON.decode(params[:data])
          submit(data, client)
        end

        # Can be called when the form needs to load a record with given ID. E.g.:
        #
        #     someForm.server.load({id: 100});
        endpoint :load do |params|
          @record = model_class && model_adapter.find_record(params[:id])
          client.set_form_values js_record_data
        end

        # Returns options for a combobox
        # params receive:
        # +attr+ - column's name
        # +query+ - what's typed-in in the combobox
        # +id+ - selected record id
        endpoint :get_combobox_options do |params|
          attr = fields[params[:attr].to_sym]
          client.data = model_adapter.combo_data(attr, params[:query])
        end
      end
    end
  end
end
