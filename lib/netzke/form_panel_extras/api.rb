module Netzke
  module FormPanelExtras
    module Api
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
            flash :error => exc.message
            success = false
            break
          end
        end
    
        if success && @record.save
          {:this => {:set_form_values => @record.to_array(fields)}}
        else
          # flash eventual errors
          @record.errors.each_full do |msg|
            flash :error => msg
          end
          {:this => {:feedback => @flash}}
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
      def get_combo_box_options(params)
        column = params[:column]
        query = params[:query]
    
        {:data => config[:data_class_name].constantize.choices_for(column, query).map{|s| [s]}}
      end
      
      # Returns array of form values according to the configured fields
      def array_of_values
        @record && @record.to_array(fields)
      end
      
    end
  end
end