require 'activerecord'
require 'searchlogic'
require 'will_paginate'

module Netzke
  class GridPanel < Base
    module GridPanelApi
      
      #
      # Grid's native API
      # 
      
      def get_data(params = {})
        if !ext_config[:prohibit_read]
          records = get_records(params)
          {:data => records.map{|r| r.to_array(columns, self)}, :total => ext_config[:enable_pagination] && records.total_entries}
        else
          flash :error => "You don't have permissions to read data"
          {:feedback => @flash}
        end
      end

      def post_data(params)
        mod_records = {}
        [:create, :update].each do |operation|
          data = ActiveSupport::JSON.decode(params["#{operation}d_records"]) if params["#{operation}d_records"]
          if !data.nil? && !data.empty? # data may be nil for one of the operations
            mod_records[operation] = process_data(data, operation)
            mod_records[operation] = nil if mod_records[operation].empty?
          end
        end
        
        on_data_changed
        
        {
          :update_new_records => mod_records[:create], 
          :update_mod_records => mod_records[:update] || {},
          :feedback => @flash
        }
      end

      def delete_data(params)
        if !ext_config[:prohibit_delete]
          record_ids = ActiveSupport::JSON.decode(params[:records])
          data_class.destroy(record_ids)
          on_data_changed
          {:feedback => "Deleted #{record_ids.size} record(s)", :load_store_data => get_data}
        else
          {:feedback => "You don't have permissions to delete data"}
        end
      end

      def resize_column(params)
        raise "Called api_resize_column while not configured to do so" if ext_config[:enable_column_resize] == false
        columns[normalize_index(params[:index].to_i)][:width] = params[:size].to_i
        save_columns!
        {}
      end

      def move_column(params)
        raise "Called api_move_column while not configured to do so" if ext_config[:enable_column_move] == false
        remove_from = normalize_index(params[:old_index].to_i)
        insert_to = normalize_index(params[:new_index].to_i)
        column_to_move = columns.delete_at(remove_from)
        columns.insert(insert_to, column_to_move)
        save_columns!

        # reorder the columns on the client side (still not sure if it's not an overkill)
        # {:reorder_columns => columns.map(&:name)} # Well, I think it IS an overkill - commented out 
        # until proven to be necessary
        {}
      end

      def hide_column(params)
        raise "Called api_hide_column while not configured to do so" if ext_config[:enable_column_hide] == false
        columns[normalize_index(params[:index].to_i)][:hidden] = params[:hidden].to_b
        save_columns!
        {}
      end

      # Returns choices for a column
      def get_combobox_options(params)
        column = params[:column]
        query = params[:query]
        {:data => data_class.options_for(column, query).map{|s| [s]}}
        # {:data => data_class.options_for(column, query).map{|s| [s]}}
      end

      def move_rows(params)
        if defined?(ActsAsList) && data_class.ancestors.include?(ActsAsList::InstanceMethods)
          ids = JSON.parse(params[:ids]).reverse
          ids.each_with_index do |id, i|
            r = data_class.find(id)
            r.insert_at(params[:new_index].to_i + i + 1)
          end
          on_data_changed
        else
          raise RuntimeError, "Data class should 'acts_as_list' to support moving rows"
        end
        {}
      end
      
      # Create record with a form
      def create_new_record(params)
        form_data = ActiveSupport::JSON.decode(params[:data])
        res = aggregatee_instance(:new_record_form).create_or_update_record(form_data)
      
        if res[:set_form_values]
          # successful creation
          on_data_changed
          res[:set_form_values] = nil
          res[:on_successfull_record_creation] = true
        end
        res
      end
    
      #
      # Some aggregatees' overridden API 
      # 
    
      ## Edit in form specific API
      def new_record_form__netzke_submit(params)
        res = aggregatee_instance(:new_record_form).netzke_submit(params)
      
        if res[:set_form_values]
          # successful creation
          on_data_changed
          res[:set_form_values] = nil
          res.merge!({
            :parent => {:on_successfull_record_creation => true}
          })
        end
        res.to_nifty_json
      end

      def edit_form__netzke_submit(params)
        res = aggregatee_instance(:edit_form).netzke_submit(params)
      
        on_data_changed if check_for_positive_result(res)
      
        res.to_nifty_json
      end

      def multi_edit_form__netzke_submit(params)
        ids = ActiveSupport::JSON.decode(params.delete(:ids))

        res = {}
        ids.each do |id|
          form_instance = aggregatee_instance(:edit_form, :record => data_class.find(id))
          res = form_instance.netzke_submit(params)
          break if !res[:set_form_values]
        end
      
        on_data_changed if check_for_positive_result(res)
      
        res.to_nifty_json
      end
      
      protected
        # Override this method to react on each operation that caused changing of data
        def on_data_changed; end
    
        # Given an index of a column among enabled (non-excluded) columns, provides the index (position) in the table
        def normalize_index(index)
          norm_index = 0
          index.times do
            while true do
              norm_index += 1 
              break unless columns[norm_index][:included] == false
            end
          end
          norm_index
        end

        # Returns searchlogic's search with all the conditions
        def get_search(params)
          @search ||= begin
            # make params coming from Ext grid filters understandable by searchlogic
            search_params = normalize_params(params)

            # merge with conditions coming from the config
            search_params[:conditions].deep_merge!(config[:conditions] || {})

            # merge with extra conditions (in searchlogic format, come from the extended search form)
            search_params[:conditions].deep_merge!(
              normalize_extra_conditions(ActiveSupport::JSON.decode(params[:extra_conditions]))
            ) if params[:extra_conditions]

            search = data_class.search(search_params)
      
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

        # Params: 
        # <tt>:operation</tt>: :update or :create
        def process_data(data, operation)
          success = true
          # mod_record_ids = []
          mod_records = {}
          if !ext_config[:"prohibit_#{operation}"]
            modified_records = 0
            data.each do |record_hash|
              id = record_hash.delete('id')
              record = operation == :create ? data_class.new : data_class.find(id)
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

        # Converts Ext.ux.grid.GridFilters filters to searchlogic conditions, e.g.
        #     {"0" => {
        #       "data" => {
        #         "type" => "numeric", 
        #         "comparison" => "gt", 
        #         "value" => 10 }, 
        #       "field" => "id"
        #     }, 
        #     "1" => {
        #       "data" => {
        #         "type" => "string",
        #         "value" => "pizza"
        #       },
        #       "field" => "food_name"
        #     }}
        #     
        #      => 
        #     
        #     {"id_gt" => 100, "food_name_contains" => "pizza"}
        def convert_filters(column_filter)
          res = {}
          column_filter.each_pair do |k,v|
            field = v["field"].dup

            case v["data"]["type"]
            when "string"
              field << "_contains"
            when "numeric", "date"
              field << "_#{v["data"]["comparison"]}"
            end
          
            value = v["data"]["value"]
            res.merge!({field => value})
          end
          res
        end

        def normalize_extra_conditions(conditions)
          conditions.deep_convert_keys{|k| k.to_s.gsub("__", "_").to_sym}
        end

        # make params understandable to searchlogic
        def normalize_params(params)
          # filters
          conditions = params[:filter] && convert_filters(params[:filter])
        
          normalized_conditions = {}
          conditions && conditions.each_pair do |k, v|
            normalized_conditions.merge!(k.gsub("__", "_") => v)
          end
  
          {:conditions => normalized_conditions}
        end
    
        def check_for_positive_result(res)
          if res[:set_form_values]
            # successful creation
            res[:set_form_values] = nil
            res.merge!({
              :parent => {:on_successfull_edit => true}
            })
            true
          else
            false
          end
        end

    end
  end
end