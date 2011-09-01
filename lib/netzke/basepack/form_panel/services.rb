module Netzke
  module Basepack
    class FormPanel < Netzke::Base
      module Services
        extend ActiveSupport::Concern

        included do

          #
          # Endpoints

          # Called when the form gets submitted (e.g. by pressing the Apply button)
          endpoint :netzke_submit, :pre => true do |params|
            netzke_submit(params)
          end

          # Can be called when the form needs to load a record with given ID. E.g.:
          #
          #     someForm.netzkeLoad({id: 100});
          endpoint :netzke_load do |params|
            @record = data_class && data_class.find_by_id(params[:id])
            {:set_form_values => js_record_data}
          end

          # Returns options for a combobox
          endpoint :get_combobox_options do |params|
            query = params[:query]

            field = fields[params[:column].to_sym]
            scope = field.to_options[:scope]
            query = params[:query]
            {:data => combobox_options_for_column(field, :query => query, :scope => scope, :record_id => params[:id])}
          end

        end

        # Overriding configuration_panel's get_combobox_options endpoint call
        def configuration_panel__fields__get_combobox_options(params)
          query = params[:query]
          {:data => (default_columns.map{ |c| c[:name].to_s }).grep(/^#{query}/).map{ |n| [n] }}.to_nifty_json
        end

        # Returns array of form values according to the configured columns
        # def array_of_values
        #   @record && @record.to_array(fields)
        # end

        def values
          record && record.to_hash(fields)
        end

        # Implementation for the "netzke_submit" endpoint (for backward compatibility)
        def netzke_submit(params)
          data = ActiveSupport::JSON.decode(params[:data])

          # File uploads are in raw params instead of "data" hash, so, mix them in into "data"
          if config[:file_upload]
            Netzke::Core.controller.params.each_pair do |k,v|
              data[k] = v if v.is_a?(ActionDispatch::Http::UploadedFile)
            end
          end

          success = create_or_update_record(data)

          if success
            {:set_form_values => js_record_data, :set_result => true}
          else
            # flash eventual errors
            @record.errors.to_a.each do |msg|
              flash :error => msg
            end
            {:netzke_feedback => @flash, :apply_form_errors => build_form_errors(record)}
          end
        end

        private

          # Builds the form errors
          def build_form_errors(record)
            form_errors = {}
            foreign_keys = {}

            # Build a hash of foreign keys and the associated model
            data_class.reflect_on_all_associations(:belongs_to).map{ |r|
              foreign_keys[r.association_foreign_key.to_sym] = r.name
            }

            record.errors.map{|field, error|
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
            @record ||= data_class.find(:first, :conditions => {data_class.primary_key => hsh.delete(data_class.primary_key)}) # only pick up the record specified in the params if it was not provided in the configuration
            success = true

            @record = data_class.new if @record.nil?

            hsh.each_pair do |k,v|
              @record.set_value_for_attribute(fields[k.to_sym].nil? ? {:name => k} : fields[k.to_sym], v)
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
            success && @record.save
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
