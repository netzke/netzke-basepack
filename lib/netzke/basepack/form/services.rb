module Netzke
  module Basepack
    class Form < Netzke::Base
      module Services
        extend ActiveSupport::Concern

        def submit(data, this)
          # File uploads are in raw params instead of "data" hash, so, mix them in into "data"
          controller.params.each_pair do |k,v|
            data[k] = v if v.is_a?(ActionDispatch::Http::UploadedFile)
          end

          success = create_or_update_record(data)

          if success
            this.set_form_values(js_record_data)
            this.success = true # respond to classic form submission with {success: true}
            this.on_submit_success # inform the Netzke endpoint caller about success
          else
            errors = data_adapter.errors_array(@record).map do |error|
              {level: :error, msg: error}
            end
            this.netzke_feedback(errors)
            this.apply_form_errors(build_form_errors(record))
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

          # only pick the record specified in the params if it was not provided in the configuration
          @record ||= data_adapter.find_record hsh.delete(data_class.primary_key.to_s)

          #data_class.find(:first, :conditions => {data_class.primary_key => hsh.delete(data_class.primary_key)})
          success = true

          @record = data_class.new if @record.nil?

          hsh.each_pair do |k,v|
            data_adapter.set_record_value_for_attribute(@record, fields[k.to_sym].nil? ? {:name => k} : fields[k.to_sym], v)
          end

          # did we have complete success?
          success && data_adapter.save_record(@record)
        end
      end
    end
  end
end
