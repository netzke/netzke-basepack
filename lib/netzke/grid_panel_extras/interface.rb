module Netzke
  module GridPanelExtras
    module Interface
      def post_data(params)
        [:create, :update].each do |operation|
          data = JSON.parse(params.delete("#{operation}d_records".to_sym)) if params["#{operation}d_records".to_sym]
          process_data(data, operation) if !data.nil?
        end
        {:success => true, :flash => @flash}
      end
  
      def get_data(params = {})
        if @permissions[:read]
          records = get_records(params)
          {:data => records, :total => records.total_records}
        else
          flash :error => "You don't have permissions to read data"
          {:success => false, :flash => @flash}
        end
      end

      def delete_data(params = {})
        if @permissions[:delete]
          record_ids = JSON.parse(params.delete(:records))
          klass = config[:data_class_name].constantize
          klass.delete(record_ids)
          flash :notice => "Deleted #{record_ids.size} record(s)"
          success = true
        else
          flash :error => "You don't have permissions to delete data"
          success = false
        end
        {:success => success, :flash => @flash}
      end

      def resize_column(params)
        raise "Called interface_resize_column while not configured to do so" unless config[:ext_config][:enable_column_resize]
        if layout_manager_class
          l_item = layout_manager_class.by_widget(id_name).items[params[:index].to_i]
          l_item.width = params[:size]
          l_item.save!
        end
        {}
      end
  
      def move_column(params)
        raise "Called interface_move_column while not configured to do so" unless config[:ext_config][:enable_column_move]
        if layout_manager_class
          layout_manager_class.by_widget(id_name).move_item(params[:old_index].to_i, params[:new_index].to_i)
        end
        {}
      end

      # Return the choices for the column
      def get_cb_choices(params)
        column = params[:column]
        query = params[:query]
    
        {:data => config[:data_class_name].constantize.choices_for(column, query).map{|s| [s]}}
      end
  
  
      protected

      # operation => :update || :create
      def process_data(data, operation)
        if @permissions[operation]
          klass = config[:data_class_name].constantize
          modified_records = 0
          data.each do |record_hash|
            id = record_hash.delete('id')
            record = operation == :create ? klass.create : klass.find(id)
            success = true
        
            # process all attirubutes for the same record (OPTIMIZE: we can use update_attributes separately for regular attributes to speed things up)
            record_hash.each_pair do |k,v|
              begin
                record.send("#{k}=",v)
              rescue ArgumentError => exc
                flash :error => exc.message
                success = false
                break
              end
            end
        
            # try to save
            modified_records += 1 if success && record.save

            # flash eventual errors
            record.errors.each_full do |msg|
              flash :error => msg
            end
        
            flash :notice => "#{operation.to_s.capitalize}d #{modified_records} record(s)"
          end
        else
          flash :error => "You don't have permissions to #{operation} data"
        end
      end
  
      # get records
      def get_records(params)
        search_params = normalize_params(params)  # make params coming from the browser understandable by searchlogic
        search_params[:conditions].recursive_merge!(config[:conditions] || {})  # merge with conditions coming from the config
    
        raise ArgumentError, "No data_class_name specified for widget '#{config[:name]}'" if !config[:data_class_name]
        records = config[:data_class_name].constantize.all(search_params.clone) # clone needed as searchlogic removes :conditions key from the hash
        # output_array = []
        columns = get_columns
        output_array = records.map{|r| r.to_array(columns)}
    
        # records.each do |r|
        #   r_array = []
        #   self.get_columns.each do |column|
        #     r_array << r.send(column[:name])
        #   end
        #   output_array << r_array
        #   output_array << r.to_array(columns)
        # end

        # add total_entries accessor to the result
        class << output_array
          attr :total_records, true
        end
        total_records_count = config[:data_class_name].constantize.count(search_params)
        output_array.total_records = total_records_count

        output_array
      end
  
      def convert_filters(column_filter)
        res = {}
        column_filter.each_pair do |k,v|
          field = v["field"]
          case v["data"]["type"]
          when "string"
            field << "_contains"
          when "numeric"
            field << "_#{v["data"]["comparison"]}"
          end
          value = v["data"]["value"]
          res.merge!({field => value})
        end
        res
      end
  
      # make params understandable to searchlogic
      def normalize_params(params)
        # filters
        conditions = params[:filter] && convert_filters(params[:filter])
    
        normalized_conditions = {}
        conditions && conditions.each_pair do |k, v|
          assoc, method = k.split('__')
          normalized_conditions.merge!(method.nil? ? {assoc => v} : {assoc => {method => v}})
        end
    
        # sorting
        order_by = if params[:sort]
          assoc, method = params[:sort].split('__')
          method.nil? ? assoc : {assoc => method}
        end
    
        page = params[:start].to_i/params[:limit].to_i + 1 if params[:limit]
        {:per_page => params[:limit], :page => page, :order_by => order_by, :order_as => params[:dir], :conditions => normalized_conditions}
      end
    end
  end
end