module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      module Columns
        extend ActiveSupport::Concern

        COLUMN_METHOD_NAME = "%s_column"

        module ClassMethods
          # Overrides a column config, e.g.:
          #
          #     column :title do |c|
          #       c.flex = 1
          #     end
          def column(name, &block)
            method_name = COLUMN_METHOD_NAME % name
            define_method(method_name, &block)
          end
        end

        # Returns the list of (non-normalized) columns to be used. By default returns the list of model column names.
        # Can be overridden.
        def columns
          config.columns || data_adapter.model_attributes
        end

        # An array of complete columns configs ready to be passed to the JS side.
        # The +options+ hash can have the following keys:
        #   * :with_excluded - when true, include the columns that are marked as excluded
        #   * :with_meta - when true, include the meta column
        def final_columns(options = {})
          @_final_columns ||= {}
          @_final_columns[options] ||= [].tap do |cols|
            initial_columns(true).each do |c|
              name = c.name

              # merge with column declaration
              send(:"#{name}_column", c) if respond_to?(:"#{name}_column")

              # set the defaults as lowest priority
              augment_column_config(c)

              cols << c if options[:with_excluded] || !c.excluded
            end

            append_meta_column(cols) if options[:with_meta]
          end
        end

        # Columns as a hash, for easier access to a specific column
        def final_columns_hash
          @_final_columns_hash ||= final_columns.inject({}){|r,c| r.merge(c[:name].to_sym => c)}
        end

        # Columns from config.columns or the `columns` method, after normalization
        def initial_columns(with_excluded = false)
          @_initial_columns ||= {}
          @_initial_columns[with_excluded] ||= [].tap do |cols|
            has_primary_column = false

            columns.each do |c|
              # normalize:
              # * :title => {name: 'title'}
              # * {name: :some_column} => {name: 'some_column'}
              c = ActiveSupport::OrderedOptions.new.replace(c.is_a?(Symbol) ? {name: c.to_s} : c.merge(name: c[:name].to_s))

              cols << c if with_excluded || !c.excluded

              # detect primary key column
              has_primary_column ||= c.name == data_adapter.primary_key_name
            end

            # automatically add a column that reflects the primary key
            cols.insert(0, ActiveSupport::OrderedOptions.new.replace(:name => data_adapter.primary_key_name)) unless has_primary_column
          end
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

        # default_value for the meta column; used when a new record is being created in the grid
        def meta_default_data
          default_association_values(final_columns_hash).present? ? { :association_values => default_association_values(final_columns_hash).literalize_keys } : {}
        end

        # Override it when you need extra meta data to be passed through the meta column
        def meta_data(r)
          { :association_values => data_adapter.assoc_values(r, final_columns_hash).literalize_keys }
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
          set_default_attr_type(c)
          set_default_xtype(c)
          set_default_virtual(c)
          set_default_text(c)
          set_default_editable(c)
          set_default_editor(c)
          set_default_width(c)
          set_default_hidden(c)
          set_default_sortable(c)
          set_default_filterable(c)
          c[:assoc] = association_attr?(c) # needed on the JS side
        end

        def set_default_attr_type(c)
          c[:attr_type] ||= association_attr?(c) ? :integer : data_adapter.attr_type(c.name)
        end

        def set_default_xtype(c)
          return if c[:renderer] || c[:editor] # if user set those manually, we don't mess with column xtype
          c[:xtype] ||= attr_type_to_xtype_map[c[:attr_type]]
        end

        def set_default_text(c)
          c[:text] ||= c[:label] || data_class.human_attribute_name(c[:name])
        end

        def set_default_editor(c)
          # if shouldn't be editable, don't set any default editor; also, specifying xtype takes care of the editor
          return if c[:read_only] || c[:editable] == false

          if association_attr?(c)
            set_default_association_editor(c)
          else
            c[:editor] ||= editor_for_attr_type(c[:attr_type])
          end

        end

        def set_default_width(c)
          c[:width] ||= 50 if c[:attr_type] == :boolean
          c[:width] ||= 150 if c[:attr_type] == :datetime
        end

        def set_default_hidden(c)
          c[:hidden] = true if primary_key_attr?(c) && c[:hidden].nil?
        end

        def set_default_editable(c)
          if c[:editable].nil?
            c[:editable] = is_editable_column?(c)
          end
        end

        def set_default_sortable(c)
          # this *has* to be set to false if we don't want the column to be sortable (it's sortable by default in Ext)
          c[:sortable] = !(c[:virtual] && !c[:sorting_scope]) if c[:sortable].nil?
        end

        def set_default_filterable(c)
          c[:filterable] = !c[:virtual] if c[:filterable].nil?
        end


        # Detects an association column and sets up the proper editor.
        def set_default_association_editor(c)
          assoc, assoc_method =  c[:name].split('__')
          return unless assoc

          assoc_method_type = data_adapter.get_assoc_property_type assoc, assoc_method

          # if association column is boolean, display a checkbox (or alike), otherwise - a combobox (or alike)
          if c[:nested_attribute]
            c[:editor] ||= editor_for_attr_type(assoc_method_type)
          else
            c[:editor] ||= assoc_method_type == :boolean ? editor_for_attr_type(:boolean) : editor_for_association
          end
        end

        # If the column should be editable
        def is_editable_column?(c)
          not_editable_if = primary_key_attr?(c)
          not_editable_if ||= c[:virtual] && !association_attr?(c[:name])
          not_editable_if ||= c[:read_only]

          editable_if = data_class.column_names.include?(c[:name])
          editable_if ||= data_class.instance_methods.map(&:to_s).include?("#{c[:name]}=")
          editable_if ||= association_attr?(c[:name])

          editable_if && !not_editable_if
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
            update_state(:columns_order, initial_columns_order) if columns_have_changed?
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

        # Column editor config for attribute type.
        def editor_for_attr_type(type)
          {:xtype => attr_type_to_editor_xtype_map[type] || :textfield}
        end

        # Column editor config for one-to-many association
        def editor_for_association
          {:xtype => :netzkeremotecombo}
        end

        # Hash that maps a column type to the editor xtype. Override if you want different editors.
        def attr_type_to_editor_xtype_map
          {
            :integer => :numberfield,
            :boolean => :checkbox,
            :date => :datefield,
            :datetime => :xdatetime,
            :text => :textarea,
            :string => :textfield
          }
        end

        def attr_type_to_xtype_map
          {
            # :integer  => :numbercolumn, # don't like the default formatter
            :boolean  => :checkcolumn,
            :date     => :datecolumn,
            #:datetime => :datecolumn # TODO: replace with datetimepicker
          }
        end

        # Default fields that will be displayed in the Add/Edit/Search forms
        # When overriding this method, keep in mind that the fields inside the layout must be expanded (each field represented by a hash, not just a symbol)
        def default_fields_for_forms
          selected_columns = final_columns.select do |c|
            data_class.column_names.include?(c[:name]) ||
            data_class.instance_methods.include?("#{c[:name]}=") ||
            association_attr?(c[:name])
          end

          selected_columns.map do |c|
            field_config = {
              :name => c[:name],
              :field_label => c[:text] || c[:header]
            }

            # scopes for combobox options
            field_config[:scopes] = c[:editor][:scopes] if c[:editor].is_a?(Hash)

            field_config.merge!(c[:editor] || {})

            field_config
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

        # Recursively traversess items (an array) and yields each found field (a hash with :name set)
        def each_attr_in(items)
          items.each do |item|
            if item.is_a?(Hash)
              each_attr_in(item[:items]) if item[:items].is_a?(Array)
              yield(item) if item[:name]
            end
          end
        end
      end
    end
  end
end
