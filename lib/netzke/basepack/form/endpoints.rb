module Netzke
  module Basepack
    class Form < Netzke::Base
      module Endpoints
        extend ActiveSupport::Concern

        included do
          # Called when the form gets submitted (e.g. by pressing the Apply button)
          endpoint :netzke_submit do |params, this|
            data = ActiveSupport::JSON.decode(params[:data])
            submit(data, this)
          end

          # Can be called when the form needs to load a record with given ID. E.g.:
          #
          #     someForm.netzkeLoad({id: 100});
          endpoint :netzke_load do |params, this|
            @record = data_class && data_adapter.find_record(params[:id])
            this.set_form_values js_record_data
          end

          # Returns options for a combobox
          # params receive:
          # +attr+ - column's name
          # +query+ - what's typed-in in the combobox
          # +id+ - selected record id
          endpoint :get_combobox_options do |params, this|
            attr = fields[params[:attr].to_sym]
            this.data = data_adapter.combo_data(attr, params[:query])
          end
        end
      end
    end
  end
end
