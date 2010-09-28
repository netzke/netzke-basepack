module Netzke::Component
  class FormPanel < Base
    module Services
      extend ActiveSupport::Concern
      
      included do
        
        #
        # Endpoints
        # 
        endpoint :netzke_submit do |params|
          success = create_or_update_record(params)

          if success
            {:set_form_values => @record.to_hash(fields), :set_result => "ok"}
          else
            # flash eventual errors
            @record.errors.each_full do |msg|
              flash :error => msg
            end
            {:feedback => @flash}
          end
        end
        
        endpoint :netzke_load do |params|
          @record = data_class && data_class.find_by_id(params[:id])
          {:set_form_values => @record.to_hash(fields)}
        end
        
        # Returns options for a combobox
        endpoint :get_combobox_options do |params|
          column = params[:column]
          query = params[:query]

          column = fields.detect{ |c| c[:name] == params[:column] }.try(:to_options!)
          scopes = column.to_options[:scopes]
          query = params[:query]

          {:data => combobox_options_for_column(column, :query => query, :scopes => scopes, :record_id => params[:id])}
        end
        
      end

      # Overriding configuration_panel's get_combobox_options endpoint call
      def configuration_panel__fields__get_combobox_options(params)
        query = params[:query]
        {:data => (default_columns.map{ |c| c[:name].to_s }).grep(/^#{query}/).map{ |n| [n] }}.to_nifty_json
      end
  
      private
      
        # Creates/updates a record from hash
        def create_or_update_record(params)
          hsh = ActiveSupport::JSON.decode(params[:data])
          hsh.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]
          @record ||= data_class.find(:first, :conditions => {data_class.primary_key => hsh.delete(data_class.primary_key)}) # only pick up the record specified in the params if it was not provided in the configuration
          success = true

          @record = data_class.new if @record.nil?

          hsh.each_pair do |k,v|
            begin
              @record.send("#{k}=",v)
            rescue StandardError => exc
              flash :error => exc.message
              success = false
              break
            end
          end
    
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
  
        # Returns array of form values according to the configured columns
        def array_of_values
          @record && @record.to_array(fields)
        end
        
    end
  end
end