module Netzke
  module GridPanelApi
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
      {
        :update_new_records => mod_records[:create], 
        :update_mod_records => mod_records[:update] || {},
        :feedback => @flash
      }
    end

    def get_data(params = {})
      if !ext_config[:prohibit_read]
        records = get_records(params)
        {:data => records.map{|r| r.to_array(normalized_columns, self)}, :total => ext_config[:enable_pagination] && records.total_entries}
      else
        flash :error => "You don't have permissions to read data"
        {:feedback => @flash}
      end
    end

    def delete_data(params = {})
      if !ext_config[:prohibit_delete]
        record_ids = ActiveSupport::JSON.decode(params[:records])
        klass = config[:data_class_name].constantize
        klass.delete(record_ids)
        {:feedback => "Deleted #{record_ids.size} record(s)", :load_store_data => get_data}
      else
        {:feedback => "You don't have permissions to delete data"}
      end
    end

    def resize_column(params)
      raise "Called api_resize_column while not configured to do so" if ext_config[:enable_column_resize] == false
      column_at(params[:index].to_i)[:width] = params[:size].to_i
      save_columns!
      {}
    end

    def hide_column(params)
      raise "Called api_hide_column while not configured to do so" if ext_config[:enable_column_hide] == false
      column_at(params[:index].to_i)[:hidden] = params[:hidden].to_b
      save_columns!
      {}
    end

    def move_column(params)
      raise "Called api_move_column while not configured to do so" if ext_config[:enable_column_move] == false
      column_to_move = columns.delete_at(params[:old_index].to_i)
      columns.insert(params[:new_index].to_i, column_to_move)
      save_columns!

      # reorder the columns on the client side (still not sure if it's not an overkill)
      # {:reorder_columns => columns.map(&:name)} # Well, I think it IS an overkill - commented out 
      # until proven to be necessary
      {}
    end

    # Return the choices for the column
    def get_combobox_options(params)
      column = params[:column]
      query = params[:query]
      {:data => config[:data_class_name].constantize.options_for(column, query).map{|s| [s]}}
    end

    # Returns searchlogic's search with all the conditions
    def get_search(params)
      @search ||= begin
        raise ArgumentError, "No data_class_name specified for widget '#{name}'" if !config[:data_class_name]

        # make params coming from Ext grid filters understandable by searchlogic
        search_params = normalize_params(params)

        # merge with conditions coming from the config
        search_params[:conditions].deep_merge!(config[:conditions] || {})

        # merge with extra conditions (in searchlogic format, come from the extended search form)
        search_params[:conditions].deep_merge!(
          normalize_extra_conditions(ActiveSupport::JSON.decode(params[:extra_conditions]))
        ) if params[:extra_conditions]

        search = config[:data_class_name].constantize.search(search_params)
      
        # applying scopes
        scopes.each do |s|
          if s.is_a?(Array)
            scope_name, *args = s
            search.send(scope_name, *args)
          else
            search.send(s, true)
          end
        end
      
        search
      end
    end

    def configuration_panel__columns__get_combobox_options(params)
      query = params[:query]
      
      data_arry = case params[:column]
                  when "name"
                    predefined_columns.map{ |c| c[:name].to_s }
                  else
                    raise RuntimeError, "Don't know about options for column '#{params[:column]}'"
                  end
      
      {:data => data_arry.grep(/^#{query}/).map{ |n| [n] }}.to_nifty_json
    end
    
    protected

    # operation => :update || :create
    def process_data(data, operation)
      success = true
      # mod_record_ids = []
      mod_records = {}
      if !ext_config["prohibit_#{operation}".to_sym]
        klass = config[:data_class_name].constantize
        modified_records = 0
        data.each do |record_hash|
          id = record_hash.delete('id')
          record = operation == :create ? klass.new : klass.find(id)
          success = true

          # merge with strong default attirbutes
          record_hash.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]
          
          # process all attirubutes for this record
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
          mod_records[id] = record.to_array(columns, self) if success && record.save
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
    end

    # get records
    def get_records(params)
      # Restore params from widget_session if requested
      if params[:with_last_params]
        params = widget_session[:last_params]
      else
        # remember the last params
        widget_session[:last_params] = params
      end
      
      search = get_search(params)
      
      # sorting
      if params[:sort]
        assoc, method = params[:sort].split('__')
        sort_string = method.nil? ? assoc : "#{assoc}_#{method}"
        sort_string = (params[:dir] == "ASC" ? "ascend_by_" : "descend_by_") + sort_string
        search.order(sort_string)
      end
      
      # pagination
      if ext_config[:enable_pagination]
        per_page = ext_config[:rows_per_page]
        page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
        search.paginate(:per_page => per_page, :page => page)
      else
        search.all
      end
    end
    
    # Create record with form
    def create_new_record(params)
      form_data = ActiveSupport::JSON.decode(params[:data])
      res = aggregatee_instance(:new_record_form).create_or_update_record(form_data)
      
      if res[:set_form_values]
        # successful creation
        res[:set_form_values] = nil
        res[:on_successfull_record_creation] = true
      end
      res
    end
    
    # Move rows 
    def move_rows(params)
      if defined?(ActsAsList) && data_class.ancestors.include?(ActsAsList::InstanceMethods)
        ids = JSON.parse(params[:ids]).reverse
        ids.each_with_index do |id, i|
          r = data_class.find(id)
          r.insert_at(params[:new_index].to_i + i + 1)
        end
      else
        raise RuntimeError, "Data class should 'acts_as_list' to support moving rows"
      end
      {}
    end

    # When providing the edit_form aggregatee, fill in the form with the requested record
    def load_aggregatee_with_cache(params)
      if params[:id] == 'editForm'
        aggregatees[:edit_form].merge!(:record_id => params[:record_id])
      end
      
      super
    end
    
    # Search scopes, in searchlogic format
    def scopes
      @scopes ||= config[:scopes] || []
    end

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
    def convert_filters(column_filter)
      res = {}
      column_filter.each_pair do |k,v|
        field = v["field"].dup
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

    def normalize_extra_conditions(conditions)
      conditions.convert_keys{|k| k.to_s.gsub("__", "_").to_sym}
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
    
    ## Edit in form specific API
    def new_record_form__submit(params)
      form_data = ActiveSupport::JSON.decode(params[:data])
      
      # merge with strong default attirbutes
      form_data.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]
      
      res = aggregatee_instance(:new_record_form).create_or_update_record(form_data)
      
      if res[:set_form_values]
        # successful creation
        res[:set_form_values] = nil
        res.merge!({
          :parent => {:on_successfull_record_creation => true}
        })
      end
      res.to_nifty_json
    end

    def check_for_positive_result(res)
      if res[:set_form_values]
        # successful creation
        res[:set_form_values] = nil
        res.merge!({
          :parent => {:on_successfull_edit => true}
        })
      end
    end

    def edit_form__submit(params)
      form_data = ActiveSupport::JSON.decode(params[:data])
      res = aggregatee_instance(:new_record_form).create_or_update_record(form_data)
      
      check_for_positive_result(res)
      
      res.to_nifty_json
    end

    def multi_edit_form__submit(params)
      form_data = ActiveSupport::JSON.decode(params[:data])
      form_instance = aggregatee_instance(:new_record_form)
      
      ids = ActiveSupport::JSON.decode(params[:ids])

      res = {}
      ids.each do |id|
        res = form_instance.create_or_update_record(form_data.merge("id" => id))
        break if !res[:set_form_values]
      end
      
      check_for_positive_result(res)
      
      res.to_nifty_json
    end
    
  end
end