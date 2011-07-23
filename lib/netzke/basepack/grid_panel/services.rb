require 'active_record'
require 'meta_where'
require 'will_paginate'

module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      module Services
        extend ActiveSupport::Concern

        included do

          endpoint :get_data do |params|
            get_data(params)
          end

          endpoint :post_data do |params|
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
              :netzke_feedback => @flash
            }
          end

          endpoint :delete_data do |params|
            if !config[:prohibit_delete]
              record_ids = ActiveSupport::JSON.decode(params[:records])
              data_class.destroy(record_ids)
              on_data_changed
              {:netzke_feedback => I18n.t('netzke.basepack.grid_panel.deleted_n_records', :n => record_ids.size), :load_store_data => get_data}
            else
              {:netzke_feedback => I18n.t('netzke.basepack.grid_panel.cannot_delete')}
            end
          end

          endpoint :resize_column do |params|
            raise "Called resize_column endpoint while not configured to do so" if !config[:persistence]
            current_columns_order = state[:columns_order] || initial_columns_order
            current_columns_order[normalize_index(params[:index].to_i)][:width] = params[:size].to_i
            update_state(:columns_order, current_columns_order)
            {}
          end

          endpoint :move_column do |params|
            raise "Called move_column endpoint while not configured to do so" if !config[:persistence]
            remove_from = normalize_index(params[:old_index].to_i)
            insert_to = normalize_index(params[:new_index].to_i)

            current_columns_order = state[:columns_order] || initial_columns_order

            column_to_move = current_columns_order.delete_at(remove_from)
            current_columns_order.insert(insert_to, column_to_move)

            update_state(:columns_order, current_columns_order)

            {}
          end

          endpoint :hide_column do |params|
            raise "Called hide_column endpoint while not configured to do so" if !config[:persistence]
            current_columns_order = state[:columns_order] || initial_columns_order
            current_columns_order[normalize_index(params[:index].to_i)][:hidden] = params[:hidden]
            update_state(:columns_order, current_columns_order)
            {}
          end

          # Returns choices for a column
          endpoint :get_combobox_options do |params|
            query = params[:query]

            column = columns.detect{ |c| c[:name] == params[:column] }
            scope = column.to_options[:scope] || column.to_options[:editor].try(:fetch, :scope, nil)
            query = params[:query]

            {:data => combobox_options_for_column(column, :query => query, :scope => scope, :record_id => params[:id])}
          end

          endpoint :move_rows do |params|
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

        end
        #
        # Some components' overridden endpoints
        #

        ## Edit in form specific endpoint
        def add_form__form_panel0__netzke_submit_endpoint(params)
          res = component_instance(:add_form__form_panel0).netzke_submit(params)

          if res[:set_form_values]
            # successful creation
            on_data_changed
            res[:set_form_values] = nil
          end
          res.to_nifty_json
        end

        def edit_form__form_panel0__netzke_submit_endpoint(params)
          res = component_instance(:edit_form__form_panel0).netzke_submit(params)

          if res[:set_form_values]
            on_data_changed
            res[:set_form_values] = nil
          end

          res.to_nifty_json
        end

        def multi_edit_form__multi_edit_form0__netzke_submit_endpoint(params)
          ids = ActiveSupport::JSON.decode(params.delete(:ids))
          data = ids.collect{ |id| ActiveSupport::JSON.decode(params[:data]).merge("id" => id) }

          data.map!{|el| el.delete_if{ |k,v| v.is_a?(String) && v.blank? }} # only interested in set values

          mod_records_count = process_data(data, :update).count

          # remove duplicated flash messages
          @flash = @flash.inject([]){ |r,hsh| r.include?(hsh) ? r : r.push(hsh) }

          if mod_records_count > 0
            on_data_changed
            flash :notice => "Updated #{mod_records_count} records."
            {:set_result => "ok", :netzke_feedback => @flash}.to_nifty_json
          else
            {:netzke_feedback => @flash}.to_nifty_json
          end
        end

        # When providing the edit_form component, fill in the form with the requested record
        def deliver_component_endpoint(params)
          components[:edit_form][:items].first.merge!(:record_id => params[:record_id].to_i) if params[:name] == 'edit_form'
          super
        end

        # Implementation for the "get_data" endpoint
        def get_data(*args)
          params = args.first || {} # params are optional!
          if !config[:prohibit_read]
            {}.tap do |res|
              records = get_records(params)
              res[:data] = records.map{|r| r.to_array(columns(:with_meta => true))}
              res[:total] = records.total_entries if config[:enable_pagination]

              # provide association values for all records at once
              # assoc_values = get_association_values(records, columns)
              # res[:set_association_values] = assoc_values.literalize_keys if assoc_values.present?
            end
          else
            flash :error => "You don't have permissions to read data"
            { :netzke_feedback => @flash }
          end
        end

        protected

          # Returns all values for association columns, per column, per associated record id, e.g.:
          # {
          #   :author__first_name => {1 => "Vladimir", 2 => "Herman"},
          #   :author__last_name => {1 => "Nabokov", 2 => "Hesse"}
          # }
          # This is used to display the association by the specified method instead by the foreign key
          # def get_association_values(records, columns)
          #   columns.select{ |c| c[:name].index("__") }.each.inject({}) do |r,c|
          #     column_values = {}
          #     records.each{ |r| column_values[r.value_for_attribute(c)] = r.value_for_attribute(c, true) }
          #     r.merge(c[:name] => column_values)
          #   end
          # end
          def get_records(params)

            # Restore params from component_session if requested
            if params[:with_last_params]
              params = component_session[:last_params]
            else
              # remember the last params
              component_session[:last_params] = params
            end

            # build initial relation based on passed params
            relation = get_relation(params)

            # addressing the n+1 query problem
            columns.each do |c|
              assoc, method = c[:name].split('__')
              relation = relation.includes(assoc.to_sym) if method
            end

            # apply sorting if needed
            if params[:sort] && sort_params = params[:sort].first
              assoc, method = sort_params["property"].split('__')
              dir = sort_params["direction"].downcase

              # if a sorting scope is set, call the scope with the given direction
              column = columns.detect { |c| c[:name] == sort_params["property"] }
              if column.has_key?(:sorting_scope)
                relation = relation.send(column[:sorting_scope].to_sym, dir.to_sym)
              else
                relation = if method.nil?
                  relation.order(assoc.to_sym.send(dir))
                else
                  assoc = data_class.reflect_on_association(assoc.to_sym)
                  relation.order(assoc.klass.table_name.to_sym => method.to_sym.send(dir)).joins(assoc.name)
                end
              end
            end

            # apply pagination if needed
            if config[:enable_pagination]
              per_page = config[:rows_per_page]
              page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
              relation.paginate(:per_page => per_page, :page => page)
            else
              relation.all
            end
          end

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

          # Params:
          # <tt>:operation</tt>: :update or :create
          def process_data(data, operation)
            success = true
            mod_records = {}
            if !config[:"prohibit_#{operation}"]
              modified_records = 0
              data.each do |record_hash|
                id = record_hash.delete('id')
                record = operation == :create ? data_class.new : data_class.find(id)
                success = true

                # merge with strong default attirbutes
                record_hash.merge!(config[:strong_default_attrs]) if config[:strong_default_attrs]

                record_hash.each_pair do |k,v|
                  record.set_value_for_attribute(columns_hash[k.to_sym].nil? ? {:name => k} : columns_hash[k.to_sym], v)
                end

                # process all attirubutes for this record
                #record_hash.each_pair do |k,v|
                  #begin
                    #record.send("#{k}=",v)
                  #rescue ArgumentError => exc
                    #flash :error => exc.message
                    #success = false
                    #break
                  #end
                #end

                # try to save
                # modified_records += 1 if success && record.save
                mod_records[id] = record.to_array(columns(:with_meta => true)) if success && record.save
                # mod_record_ids << id if success && record.save

                # flash eventual errors
                if !record.errors.empty?
                  success = false
                  record.errors.to_a.each do |msg|
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
          #  metawhere:   :id.gt => 100, :food_name.matches => '%pizza%'
          def convert_filters(column_filter)
            # these are still JSON-encoded due to the migration to Ext.direct
            column_filter=JSON.parse(column_filter)
            res = {}
            column_filter.each do |v|
              assoc, method = v["field"].split('__')
              if method
                assoc = data_class.reflect_on_association(assoc.to_sym)
                field = [assoc.klass.table_name, method].join('.').to_sym
              else
                field = assoc.to_sym
              end

              value = v["value"]

              case v["type"]
              when "string"
                op = v['comparison'] && (v['comparison'] == 'like' ? :matches : :does_not_match) || :matches
                field = field.send(op)
                value = "%#{value}%"
              when "numeric", "date"
                field = field.send :"#{v['comparison']}"
              end
              res.merge!({field => value})
            end
            res
          end

          def normalize_extra_conditions(conditions)
            conditions.each_pair do |k,v|
              conditions[k] = "%#{v}%" if ["like", "matches"].include?(k.to_s.split("__").last)
            end
          end

      end
    end
  end
end
