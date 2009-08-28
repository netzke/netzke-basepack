module Netzke
  module FormPanelApi
    # API handling form submission
    def submit(params)
      data_hsh = ActiveSupport::JSON.decode(params[:data])
      create_or_update_record(data_hsh)
    end

    # Creates/updates a record from hash
    def create_or_update_record(hsh)
      klass = config[:data_class_name].constantize
      @record = klass.find_by_id(hsh.delete("id"))
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
  
      if success && @record.save
        {:set_form_values => @record.to_array(columns)}
      else
        # flash eventual errors
        @record.errors.each_full do |msg|
          flash :error => msg
        end
        {:feedback => @flash}
      end
    end

    # API handling form load
    def load(params)
      klass = config[:data_class_name].constantize
      case params[:neighbour]
        when "previous" then @record = klass.previous(params[:id])
        when "next"     then @record = klass.next(params[:id])
        else                 @record = klass.find(params[:id])
      end
      {:data => [array_of_values]}
    end
    
    # API that returns options for a combobox
    def get_combobox_options(params)
      column = params[:column]
      query = params[:query]
  
      {:data => config[:data_class_name].constantize.options_for(column, query).map{|s| [s]}}
    end
    
    def configuration_panel__fields__get_combobox_options(params)
      data_class = config[:data_class_name].constantize
      query = params[:query]
      {:data => (data_class.column_names + data_class.netzke_virtual_attributes.map(&:to_s)).grep(/^#{query}/).map{ |n| [n] }}.to_nifty_json
    end
    
    # Returns array of form values according to the configured columns
    def array_of_values
      @record && @record.to_array(columns)
    end
    
  end
end