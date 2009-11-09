module Netzke
  module FormPanelApi
    # API handling form submission
    def netzke_submit(params)
      success = create_or_update_record(params)

      if success
        {:set_form_values => array_of_values, :set_result => "ok"}
      else
        # flash eventual errors
        @record.errors.each_full do |msg|
          flash :error => msg
        end
        {:feedback => @flash}
      end
    end

    # Creates/updates a record from hash
    def create_or_update_record(params)
      hsh = ActiveSupport::JSON.decode(params[:data])
      hsh.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]
      klass = config[:data_class_name].constantize
      @record ||= klass.find_by_id(hsh.delete("id")) # only pick up the record specified in the params if it was not provided in the configuration
      success = true

      @record = klass.new if @record.nil?

      hsh.each_pair do |k,v|
        begin
          @record.send("#{k}=",v)
        rescue StandardError => exc
          logger.debug "!!! FormPanelApi#create_or_update_record exception: #{exc.inspect}\n"
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
    #   klass = config[:data_class_name].constantize
    #   case params[:neighbour]
    #     when "previous" then @record = klass.previous(params[:id])
    #     when "next"     then @record = klass.next(params[:id])
    #     else                 @record = klass.find(params[:id])
    #   end
    #   {:data => [array_of_values]}
    # end
    
    def netzke_load(params)
      @record = data_class && data_class.find_by_id(params[:id])
      {:set_form_values => array_of_values}
    end
    
    # API that returns options for a combobox
    def get_combobox_options(params)
      column = params[:column]
      query = params[:query]
  
      {:data => config[:data_class_name].constantize.options_for(column, query).map{|s| [s]}}
    end
    
    def configuration_panel__fields__get_combobox_options(params)
      query = params[:query]
      {:data => (predefined_columns.map{ |c| c[:name].to_s }).grep(/^#{query}/).map{ |n| [n] }}.to_nifty_json
    end
    
    # Returns array of form values according to the configured columns
    def array_of_values
      @record && @record.to_array(columns, self)
    end
    
  end
end