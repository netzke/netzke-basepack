module Netzke
  module Basepack
    class FormPanel < Netzke::Base
      module Services
        extend ActiveSupport::Concern

        included do

          #
          # Endpoints

          # Called when the form gets submitted (e.g. by pressing the Apply button)
          endpoint :netzke_submit do |params, this|
            data = ActiveSupport::JSON.decode(params[:data])
            data.each_pair do |k,v|
              data[k]=nil if v.blank? || v == "null" # Ext JS returns "null" on empty date fields, or "" for not filled optional integer fields, which gives errors when passed to model (at least in DataMapper)
            end

            # File uploads are in raw params instead of "data" hash, so, mix them in into "data"
            Netzke::Core.controller.params.each_pair do |k,v|
              data[k] = v if v.is_a?(ActionDispatch::Http::UploadedFile)
            end

            success = create_or_update_record(data)

            if success
              this.set_form_values(js_record_data)
              this.success = true # respond to classic form submission with {success: true}
              this.on_submit_success # inform the Netzke endpoint caller about success
            else
              # flash eventual errors
              data_adapter.errors_array(@record).each do |error|
                flash :error => error
              end
              this.netzke_feedback(@flash)
              this.apply_form_errors(build_form_errors(record))
            end
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

        def values
          record && record.netzke_hash(fields)
        end

      private

        # Builds the form errors
        def build_form_errors(record)
          form_errors = {}
          foreign_keys = data_adapter.hash_fk_model
          record.errors.to_hash.map{|field, error|
            # some ORM return an array for error
            error = error.join ', ' if error.kind_of? Array
            # Get the correct field name for the errors on foreign keys
            if foreign_keys.has_key?(field)
              fields.each do |k, v|
                # Hack to stop to_nifty_json from camalizing model__field
                field = k.to_s.gsub('__', '____') if k.to_s.split('__').first == foreign_keys[field].to_s
              end
            end
            form_errors[field] ||= []
            form_errors[field] << error
          }
          form_errors
        end

        # Creates/updates a record from hash
        def create_or_update_record(hsh)
          hsh.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]
          @record ||= data_adapter.find_record hsh.delete(data_class.primary_key.to_s) # only pick up the record specified in the params if it was not provided in the configuration
            #data_class.find(:first, :conditions => {data_class.primary_key => hsh.delete(data_class.primary_key)})
          success = true

          @record = data_class.new if @record.nil?

          hsh.each_pair do |k,v|
            data_adapter.set_record_value_for_attribute(@record, fields[k.to_sym].nil? ? {:name => k} : fields[k.to_sym], v, config.role || :default)
          end

          #hsh.each_pair do |k,v|
            #begin
              #@record.send("#{k}=",v)
            #rescue StandardError => exc
              #flash :error => exc.message
              #success = false
              #break
            #end
          #end

          # did we have complete success?
          success && data_adapter.save_record(@record)
        end

        # API handling form load
        # def load(params)
        #   klass = config[:model].constantize
        #   case params[:neighbour]
        #     when "previous" then @record = klass.previous(params[:id])
        #     when "next"     then @record = klass.next(params[:id])
        #     else                 @record = klass.find(params[:id])
        #   end
        #   {:data => [array_of_values]}
        # end

      end
    end
  end
end
