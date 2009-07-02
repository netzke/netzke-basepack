module Netzke
  module FormPanelExtras
    module Interface
      def submit(params)
        params.delete(:authenticity_token)
        params.delete(:controller)
        params.delete(:action)

        klass = config[:data_class_name].constantize
        @record = klass.find_by_id(params[:id])
        success = true

        @record = klass.new if @record.nil?

        params.each_pair do |k,v|
          begin
            @record.send("#{k}=",v)
          rescue StandardError => exc
            flash :error => exc.message
            success = false
            break
          end
        end
    
        if success && @record.save
          {:data => [@record.to_array(fields)], :success => true}
        else
          # flash eventual errors
          @record.errors.each_full do |msg|
            flash :error => msg
          end
          {:success => false, :flash => @flash}
        end
      end

      def load(params)
        klass = config[:data_class_name].constantize
        case params[:neighbour]
          when "previous" then @record = klass.previous(params[:id])
          when "next"     then @record = klass.next(params[:id])
          else                 @record = klass.find(params[:id])
        end
        {:data => [array_of_values]}
      end
      
      def array_of_values
        @record && @record.to_array(fields)
      end
      
      # Return the choices for the column
      def get_cb_choices(params)
        column = params[:column]
        query = params[:query]
    
        {:data => config[:data_class_name].constantize.choices_for(column, query).map{|s| [s]}}
      end
        
    end
  end
end