module Netzke
  module Basepack
    # Takes care of grid column configuration, as well as the grid's default form fields
    # +Basepack::Grid+ extends common Ext JS column options with the following ones:
    #
    # [sorting_scope]
    #
    #   A Proc object used for sorting by the column. This can be useful for sorting by a virtual column. The Proc
    #   object will get the relation as the first parameter, and the sorting direction as the second. Example:
    #
    #     columns => [{ name: "complete_user_name", sorting_scope: lambda {|rel, dir| order("users.first_name #{dir.to_s}, users.last_name #{dir.to_s}") }, ...]
    #
    # [filter_with]
    #
    #   A Proc object that receives the relation, the value to filter by and the operator. This allows for more flexible
    #   handling of basic filters and enables filtering of virtual columns. Example:
    #
    #     columns => [{ name: "complete_user_name", filter_with: lambda{|rel, value, op| rel.where("first_name like ? or last_name like ?", "%#{value}%", "%#{value}%" ) } }, ...]
    #
    # [filterable]
    #
    #   Set to false to disable filtering on this column
    #
    # [editor]
    #
    #   A hash that will override the automatic editor configuration. For example, for one-to-many association column
    #   you may set it to +{min_chars: 1}+, which will be passed to the combobox and make it query its remote data after
    #   entering 1 character (instead of default 4).
    #
    # === Configuring default filters on grid columns
    #
    # Default Filters can either be configured on the grid itself
    #
    #     def configure(c)
    #       super
    #       c.default_filters = [{name: "Mark"}, {age: {gt: 10}}]
    #     end
    #
    # or as a component configuration
    #
    #      component :tasks |c|
    #        c.klass = TaskGrid
    #        c.default_filters = [{due_date: {before: Time.now}}]
    #      end
    #
    module Columns
      extend ActiveSupport::Concern

      COLUMN_METHOD_NAME = "%s_column"

      included do
        class_attribute :declared_columns
        self.declared_columns = []
      end

      module ClassMethods
        # Adds/overrides a column config, e.g.:
        #
        #     column :title do |c|
        #       c.flex = 1
        #     end
        #
        # If a new column is declared, it gets appended to the list of default columns.
        def column(name, &block)
          method_name = COLUMN_METHOD_NAME % name
          define_method(method_name, &block)
          self.declared_columns = [*declared_columns, name]
        end
      end

      # Returns the list of (non-normalized) columns to be used. By default returns the list of model column names and declared columns.
      # Can be overridden.
      def columns
        config.columns || model_adapter.model_attributes
      end

      # An array of complete columns configs ready to be passed to the JS side.
      def final_columns
        @final_columns ||= [].tap do |cols|
          has_primary_column = false

          columns.each do |c|
            c = build_column_config(c)
            next if c.excluded

            has_primary_column ||= c.primary?
            cols << c
          end

          insert_primary_column(cols) unless has_primary_column
          append_association_values_column(cols)
        end
      end

      def build_column_config(c)
        Netzke::Basepack::ColumnConfig.new(c, model_adapter).tap do |c|
          attribute_config = attribute_overrides[c.name.to_sym]
          c.merge_attribute(attribute_config) if attribute_config
          augment_column_config(c)
        end
      end

      # Array of complete config hashes for non-meta columns
      def non_meta_columns
        @non_meta_columns ||= final_columns.reject{|c| c[:meta]}
      end

      # Columns as a hash, for easier access to a specific column
      def final_columns_hash
        @_final_columns_hash ||= final_columns.inject({}){|r,c| r.merge(c[:name].to_sym => c)}
      end

      # Columns that have to be used by the JS side of the grid
      def js_columns
        final_columns.map do |c|
          # we are removing the editor on this last step, so that the editor config is still being passed from the
          # column config to the form editor; refactor!
          c.delete(:editor) unless config.edit_inline
          c
        end
      end

      def append_association_values_column(cols)
        cols << {}.tap do |c|
          c.merge!(
            :name => "association_values",
            :meta => true,
            :getter => lambda do |r|
              model_adapter.assoc_values(r, final_columns_hash).netzke_literalize_keys
            end
          )
          defaults = association_value_defaults(cols).netzke_literalize_keys
          c[:default_value] = defaults if defaults.present?
        end
      end

      def insert_primary_column(cols)
        primary_key = model_adapter.primary_key
        raise "Model #{model_adapter.model_class.name} does not have a primary column" if primary_key.blank?
        c = Netzke::Basepack::ColumnConfig.new(model_adapter.primary_key, model_adapter)
        c.merge_attribute(attribute_overrides[c.name.to_sym]) if attribute_overrides.has_key?(c.name.to_sym)
        augment_column_config(c)
        cols.insert(0, c)
      end

      # Default form items (non-normalized) that will be displayed in the Add/Edit forms
      def default_form_items
        non_meta_columns.map{|c| c.name.to_sym}
      end

      # ATM the same attributes are used as in forms
      def attributes_for_search
        non_meta_columns.map do |c|
          {name: c.name, text: c.text, type: c.type}.tap do |a|
            if c[:assoc]
              a[:text].sub!("  ", " ")
            end
          end
        end
      end

      # Form items that will be used by the Add/Edit forms. May be useful overriding it.
      def form_items
        config.form_items || default_form_items
      end

      private

      def populate_columns_with_filters(c)
        c.default_filters.each do |filter|
          c.columns[:items].each do |column|
            if column[:name].to_sym == filter[:column].to_sym
              extend_column_with_filter(column, filter)
            end
          end
        end
        c.delete(:default_filters)
      end

      def extend_column_with_filter(column, filter)
        if filter[:value].is_a?(Hash)
          val = {}
          filter[:value].each do |k,v|
            val[k] = (v.is_a?(Time) || v.is_a?(Date) || v.is_a?(ActiveSupport::TimeWithZone)) ? Netzke::Core::JsonLiteral.new("new Date('#{v.strftime("%m/%d/%Y")}')") : v
          end
        else
          val = filter[:value]
        end
        new_filter = {value: val, active: true}
        if column[:filter]
          column[:filter].merge! new_filter
        else
          column[:filter] = new_filter
        end
      end

      # Extends passed column config with DSL declaration for this column
      def apply_column_dsl(c)
        method_name = COLUMN_METHOD_NAME % c.name
        send(method_name, c) if respond_to?(method_name)
      end

      # Based on initial column config, e.g.:
      #
      #   {:name=>"author__name", :type=>:string}
      #
      # augment it with additional configuration params, e.g.:
      #
      #   {:name=>"author__name", :type=>:string, :editor=>{:xtype=>:netzkeremotecombo}, :assoc=>true, :virtual=>true, :header=>"Author  name", :sortable=>false, :filterable=>false}
      #
      # It may be handy to override it.
      def augment_column_config(c)
        apply_column_dsl(c)
        c.set_defaults
      end

      def initial_columns_order
        non_meta_columns.map do |c|
          # copy the values that are not null
          {name: c[:name]}.tap do |r|
            r[:width] = c[:width] if c[:width]
            r[:hidden] = c[:hidden] if c[:hidden]
          end
        end
      end

      def columns_order
        if config[:persistence]
          state[:columns_order] = initial_columns_order if columns_have_changed?
          state[:columns_order] || initial_columns_order
        else
          initial_columns_order
        end
      end

      def columns_have_changed?
        init_column_names = initial_columns_order.map{ |c| c[:name].to_s }.sort
        stored_column_names = (state[:columns_order] || initial_columns_order).map{ |c| c[:name].to_s }.sort
        init_column_names != stored_column_names
      end

      def columns_default_values
        non_meta_columns.inject({}) do |r,c|
          assoc_name, assoc_method = c[:name].split '__'
          if c[:default_value].nil?
            r
          else
            if assoc_method
              r.merge(model_adapter.foreign_key_for(assoc_name) || model_adapter.foreign_key_for(assoc_name) => c[:default_value])
            else
              r.merge(c[:name] => c[:default_value])
            end
          end
        end
      end
    end
  end
end
