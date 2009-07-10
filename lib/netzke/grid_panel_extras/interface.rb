module Netzke
  module GridPanelExtras
    module Interface
      def post_data(params)
        success = true
        mod_records = {}
        [:create, :update].each do |operation|
          data = ActiveSupport::JSON.decode(params["#{operation}d_records"]) if params["#{operation}d_records"]
          if !data.nil? && !data.empty? # data may be nil for one of the operations
            mod_records[operation] = process_data(data, operation)
            mod_records[operation] = nil if mod_records[operation].empty?
          end
          break if !success
        end
        {:this => {
            :update_new_records => mod_records[:create], 
            :update_mod_records => mod_records[:update],
            :feedback => @flash.empty? ? nil : @flash
        }}
      end
  
      def get_data(params = {})
        if @permissions[:read]
          records = get_records(params)
          
          # {:data => records, :total => records.total_records}
          {:data => records.map{|r| r.to_array(columns)}, :total => records.total_entries, :this => {:feedback => "hi"}}
          # [{:load_store_data => {:data => records.map{|r| r.to_array(columns)}, :total => records.total_entries}}]
        else
          flash :error => "You don't have permissions to read data"
          {:success => false, :flash => @flash}
        end
      end

      def delete_data(params = {})
        if @permissions[:delete] && false
          record_ids = ActiveSupport::JSON.decode(params.delete(:records))
          klass = config[:data_class_name].constantize
          klass.delete(record_ids)
          {:this => {:feedback => "Deleted #{record_ids.size} record(s)", :load_store_data => get_data}}
        else
          {:this => {:feedback => "You don't have permissions to delete data"}}
        end
      end

      def resize_column(params)
        raise "Called api_resize_column while not configured to do so" unless config[:ext_config][:enable_column_resize]
        if config[:persistent_layout]
          NetzkeLayoutItem.widget = id_name
          column = NetzkeLayoutItem.find(params[:index].to_i + 1)
          column.width = params[:size].to_i
          column.save
        end
        {}
      end
  
      def hide_column(params)
        raise "Called api_hide_column while not configured to do so" unless config[:ext_config][:enable_column_hide]
        if config[:persistent_layout]
          NetzkeLayoutItem.widget = id_name
          column = NetzkeLayoutItem.find(params[:index].to_i + 1)
          column.hidden = params[:hidden].to_b
          column.save
        end
        {}
      end
  
      def move_column(params)
        raise "Called api_move_column while not configured to do so" unless config[:ext_config][:enable_column_move]
        if config[:persistent_layout]
          NetzkeLayoutItem.widget = id_name
          NetzkeLayoutItem.move_item(params[:old_index].to_i, params[:new_index].to_i)
        end

        # reorder the columns on the client side (still not sure if it's not an overkill)
        {:this => {:reorder_columns => columns.map(&:name)}}
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
        success = true
        # mod_record_ids = []
        mod_records = {}
        if @permissions[operation]
          klass = config[:data_class_name].constantize
          modified_records = 0
          data.each do |record_hash|
            id = record_hash.delete('id')
            record = operation == :create ? klass.new : klass.find(id)
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
            # modified_records += 1 if success && record.save
            mod_records[id] = record.to_array(columns) if success && record.save
            # mod_record_ids << id if success && record.save

            # flash eventual errors
            if !record.errors.empty?
              success = false
              record.errors.each_full do |msg|
                flash :error => msg
              end
            end
          end
          # flash :notice => "#{operation.to_s.capitalize}d #{modified_records} record(s)"
        else
          success = false
          flash :error => "You don't have permissions to #{operation} data"
        end
        mod_records
        # mod_record_ids
      end
  
      # get records
      def get_records(params)
        raise ArgumentError, "No data_class_name specified for widget '#{config[:name]}'" if !config[:data_class_name]

        search_params = normalize_params(params)  # make params coming from the browser understandable by searchlogic
        search_params[:conditions].recursive_merge!(config[:conditions] || {})  # merge with conditions coming from the config

        # sorting
        # order_by = if params[:sort]
        #   assoc, method = params[:sort].split('__')
        #   method.nil? ? assoc : {assoc => method}
        # end
    
    
        if config[:ext_config][:rows_per_page]
          per_page = config[:ext_config][:rows_per_page]
          page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
        end
        # , :order_by => order_by, :order_as => params[:dir], 
    
        search = config[:data_class_name].constantize.search(search_params)
        
        search.paginate(:per_page => per_page, :page => page)
      end
  
      #
      # Converts Ext.grid.GridFilters filters to searchlogic conditions, e.g.
      # {"0" => {
      #   "data" => {
      #     "type" => "numeric", 
      #     "comparison" => "gt", 
      #     "value" => 10 }, 
      #   "field" => "id"
      # }, 
      # "1" => {
      #   "data" => {
      #     "type" => "string",
      #     "value" => "pizza"
      #   },
      #   "field" => "food_name"
      # }}
      #
      #  => 
      #
      # {"id_gt" => 100, "food_name_contains" => "pizza"}
      #
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
    
        {:conditions => normalized_conditions}
      end
    end
  end
end