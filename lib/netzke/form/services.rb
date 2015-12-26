module Netzke
  module Form
    module Services
      extend ActiveSupport::Concern

      def submit(data, client)
        # File uploads are in raw params instead of "data" hash, so, mix them in into "data"
        controller.params.each_pair do |k,v|
          data[k] = v if v.is_a?(ActionDispatch::Http::UploadedFile)
        end

        success = create_or_update_record(data)

        if success
          client.netzke_set_form_values(js_record_data)
          client.success = true # respond to classic form submission with {success: true}
          client.netzke_on_submit_success # inform the Netzke endpoint caller about success
        else
          errors = model_adapter.errors_array(@record).map do |error|
            {level: :error, msg: error}
          end
          client.netzke_display_form_errors(errors)
          client.netzke_apply_form_errors(build_form_errors(record))
        end
      end

      def values
        record && record.netzke_hash(fields)
      end

      private

      # Builds the form errors
      def build_form_errors(record)
        form_errors = {}
        foreign_keys = model_adapter.hash_fk_model
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
        hsh.merge!(config[:strong_values]) if config[:strong_values]

        # only pick the record specified in the params if it was not provided in the configuration
        @record ||= model_adapter.find_record hsh.delete(model_class.primary_key.to_s)

        #model_class.find(:first, :conditions => model_class.primary_key => hsh.delete(model_class.primary_key)})
        success = true

        @record = model_class.new if @record.nil?

        hsh.each_pair do |k,v|
          model_adapter.set_record_value_for_attribute(@record, fields[k.to_sym].nil? ? {:name => k} : fields[k.to_sym], v)
        end

        # did we have complete success?
        success && model_adapter.save_record(@record)
      end
    end
  end
end
