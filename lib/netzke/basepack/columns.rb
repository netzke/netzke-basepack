module Netzke
  module Basepack
    module Columns
      extend ActiveSupport::Concern

      COLUMN_METHOD_NAME = "%s_column"

      included do
        class_attribute :declared_columns
        self.declared_columns = []
      end

      module ClassMethods
        def inherited(klass)
          klass.class_attribute :declared_columns
          klass.declared_columns = []
        end

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
          self.declared_columns << name
        end
      end

      # Returns the list of (non-normalized) columns to be used. By default returns the list of model column names and declared columns.
      # Can be overridden.
      def columns
        config.columns || default_columns
      end

      # Columns from model + columns declared with DSL
      def default_columns
        (data_adapter.model_attributes + self.class.declared_columns).uniq
      end

      # An array of complete columns configs ready to be passed to the JS side.
      # The +options+ hash can have the following keys:
      #   * :with_excluded - when true, include the columns that are marked as excluded
      #   * :with_meta - when true, include the meta column
      def final_columns(options = {})
        # memoize
        @_final_columns ||= {}
        @_final_columns[options] ||= [].tap do |cols|
          has_primary_column = false

          columns.each do |c|
            c = ColumnConfig.new(c, data_adapter)

            # merge with column declaration
            send(:"#{c.name}_column", c) if respond_to?(:"#{c.name}_column")

            # detect primary key column
            has_primary_column ||= c.primary?

            if !c.excluded || options[:with_excluded]
              # set the defaults as lowest priority
              augment_column_config(c)

              c[:editable] = false if(config[:enable_edit_inline] == false && c[:xtype] == :checkcolumn)

              cols << c # if options[:with_excluded] || !c.excluded
            end
          end

          insert_primary_column(cols) if !has_primary_column
          append_meta_column(cols) if options[:with_meta]
        end
      end

      # Columns as a hash, for easier access to a specific column
      def final_columns_hash
        @_final_columns_hash ||= final_columns.inject({}){|r,c| r.merge(c[:name].to_sym => c)}
      end

      def append_meta_column(cols)
        cols << {}.tap do |c|
          c.merge!(
            :name => "meta",
            :meta => true,
            :getter => lambda do |r|
              meta_data(r)
            end
          )
          c[:default_value] = meta_default_data if meta_default_data.present?
        end
      end

      def insert_primary_column(cols)
        c = ColumnConfig.new(data_adapter.primary_key, data_adapter)
        augment_column_config(c)
        cols.insert(0, c)
      end

      # default_value for the meta column; used when a new record is being created in the grid
      def meta_default_data
        default_association_values(final_columns_hash).present? ? { :association_values => default_association_values(final_columns_hash).netzke_literalize_keys } : {}
      end

      # Override it when you need extra meta data to be passed through the meta column
      def meta_data(r)
        { :association_values => data_adapter.assoc_values(r, final_columns_hash).netzke_literalize_keys }
      end

    protected

      # Default fields that will be displayed in the Add/Edit/Search forms
      # When overriding this method, keep in mind that the fields inside the layout must be expanded (each field represented by a hash, not just a symbol)
      def default_fields_for_forms
        columns_taken_over_to_forms.map do |c|
          (c[:editor] || {}).tap do |f|
            f[:name] = c.name
            f[:field_label] = c.text || c.header
            f[:read_only] = c.read_only

            # scopes for combobox options
            f[:scopes] = c[:editor][:scopes] if c[:editor].is_a?(Hash)
          end
        end
      end

    private

      # Based on initial column config, e.g.:
      #
      #   {:name=>"author__name", :attr_type=>:string}
      #
      # augment it with additional configuration params, e.g.:
      #
      #   {:name=>"author__name", :attr_type=>:string, :editor=>{:xtype=>:netzkeremotecombo}, :assoc=>true, :virtual=>true, :header=>"Author  name", :editable=>true, :sortable=>false, :filterable=>false}
      #
      # It may be handy to override it.
      def augment_column_config(c)
        c.set_defaults!
      end

      def initial_columns_order
        final_columns.map do |c|
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

      # Selects those columns that make sense to be shown in forms
      def columns_taken_over_to_forms
        final_columns.select do |c|
          data_adapter.attribute_names.include?(c[:name]) ||
          data_class.instance_methods.include?("#{c[:name]}=") ||
          association_attr?(c[:name])
        end
      end

      def columns_default_values
        final_columns.inject({}) do |r,c|
          assoc_name, assoc_method = c[:name].split '__'
          if c[:default_value].nil?
            r
          else
            if assoc_method
              r.merge(data_adapter.foreign_key_for(assoc_name) || data_adapter.foreign_key_for(assoc_name) => c[:default_value])
            else
              r.merge(c[:name] => c[:default_value])
            end
          end
        end
      end
    end
  end
end
