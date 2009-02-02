module Netzke
  module FormPanelExtras
    module Interface
      def submit(params)
        params.delete(:authenticity_token)
        params.delete(:controller)
        params.delete(:action)

        klass = config[:data_class_name].constantize
        record = klass.find_by_id(params[:id])
        success = true

        if record.nil?
          record = klass.create(params)
        else
          params.each_pair do |k,v|
            begin
              record.send("#{k}=",v)
            rescue ArgumentError => exc
              flash :error => exc.message
              success = false
              break
            end
          end
        end
    
        # process all attirubutes for the same record (OPTIMIZE: we can use update_attributes separately for regular attributes to speed things up)
        
        if success && record.save
          {:data => [record.to_array(get_fields)], :success => true}
        else
          # flash eventual errors
          record.errors.each_full do |msg|
            flash :error => msg
          end
          {:success => false, :flash => @flash}
        end
      end

      def load(params)
        klass = config[:data_class_name].constantize
        case params[:neighbour]
        when "previous" then record = klass.previous(params[:id])
        when "next"     then record = klass.next(params[:id])
        else                 record = klass.find(params[:id])
        end
        {:data => [record && record.to_array(get_fields)]}
      end
    end
  end
end