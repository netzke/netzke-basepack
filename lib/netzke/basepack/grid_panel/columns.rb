module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      module Columns
        extend ActiveSupport::Concern

        module ClassMethods
          # Columns to be displayed by the FieldConfigurator, "meta-columns". Each corresponds to a configuration
          # option for each column in the grid.
          def meta_columns
            [
              # Whether the column will be present in the grid, also in :hidden or :meta state. The value for this column will
              # always be sent to/from the JS grid to the server
              {:name => "included",      :attr_type => :boolean, :width => 40, :header => "Incl", :default_value => true},

              # The name of the column. May be any accessible method or attribute of the data_class.
              {:name => "name",          :attr_type => :string, :width => 200},

              # The header for the column.
              {:name => "label",         :attr_type => :string, :width => 200, :header => "Header"},

              # The default value of this column. Is used when a new row in the grid gets created.
              {:name => "default_value", :attr_type => :string, :width => 200},

              # Options for drop-downs
              {:name => "combobox_options",       :attr_type => :string, :editor => :textarea, :width => 200},

              # Whether the column is editable in the grid.
              {:name => "read_only",     :attr_type => :boolean, :header => "R/O", :tooltip => "Read-only"},

              # Whether the column will be in the hidden state (hide/show columns from the column menu, if it's enabled).
              {:name => "hidden",        :attr_type => :boolean},

              # Whether the column should have "grid filters" enabled
              # (see here: http://www.extjs.com/deploy/dev/examples/grid-filtering/grid-filter-local.html)
              {:name => "with_filters",  :attr_type => :boolean, :default_value => true, :header => "Filters"},

              #
              # Below some rarely used parameters, hidden by default (you can always un-hide them from the column menu).
              #

              # The column's width
              {:name => "width",         :attr_type => :integer, :hidden => true},

              # Whether the column should be hideable
              {:name => "hideable",      :attr_type => :boolean, :default_value => true, :hidden => true},

              # Whether the column should be sortable (why change it? normally it's hardcoded)
              {:name => "sortable",      :attr_type => :boolean, :default_value => true, :hidden => true},
            ]
          end

        end

        # Normalized columns for the grid, e.g.:
        # [{:name => :id, :hidden => true, ...}, {:name => :name, :editable => false, ...}, ...]
        def columns(only_included = true)
          @columns ||= begin
            if cols = load_columns
              filter_out_excluded_columns(cols) if only_included
              reverse_merge_equally_named_columns(cols, initial_columns)
              cols
            else
              initial_columns(only_included)
            end
          end
        end

        # Columns as a hash, for easier access to a specific column
        def columns_hash
          @columns_hash ||= columns.inject({}){|r,c| r.merge(c[:name].to_sym => c)}
        end

        # Columns that we fall back to when neither persistent columns, nor configured columns are present.
        # If there's a model-level field configuration, it's being used.
        # Otherwise the defaults straight from the ActiveRecord model ("netzke_attributes").
        # Override this method if you want to provide a fix set of columns in your subclass.
        def default_columns
          @default_columns ||= load_model_level_attrs || data_class.netzke_attributes
        end

        # Columns that represent a smart merge of default_columns and columns passed during the configuration.
        def initial_columns(only_included = true)
          # Normalize here, as from the config we can get symbols (names) instead of hashes
          columns_from_config = config[:columns] && normalize_attrs(config[:columns])


          if columns_from_config
            # automatically add a column that reflects the primary key (unless specified in the config)
            columns_from_config.insert(0, {:name => data_class.primary_key}) unless columns_from_config.any?{ |c| c[:name] == data_class.primary_key }

            # reverse-merge each column hash from config with each column hash from exposed_attributes
            # (columns from config have higher priority)
            for c in columns_from_config
              corresponding_default_column = default_columns.find{ |k| k[:name] == c[:name] }
              c.reverse_merge!(corresponding_default_column) if corresponding_default_column
            end
            columns_for_create = columns_from_config
          else
            # we didn't have columns configured in component's config, so, use the columns from the data class
            columns_for_create = default_columns
          end

          filter_out_excluded_columns(columns_for_create) if only_included

          # Make the column config complete with the defaults
          columns_for_create.each do |c|
            detect_association(c)
            set_default_header(c)
            set_default_editor(c)
            set_default_width(c)
            set_default_hidden(c)
            set_default_editable(c)
            set_default_sortable(c)
            set_default_filterable(c)
          end

          columns_for_create
        end

        private
          def filter_out_excluded_columns(cols)
            cols.reject!{ |c| c[:included] == false }
          end

          # Stores modified columns in persistent storage
          def save_columns!
            # NetzkeFieldList.update_list_for_current_authority(global_id, columns(false), original_data_class.name) if persistent_config_enabled?
          end

          def load_columns
            # NetzkeFieldList.read_list(global_id) if persistent_config_enabled?
          end

          def load_model_level_attrs
            # NetzkeModelAttrList.read_list(data_class.name) if persistent_config_enabled?
          end

          def set_default_header(c)
            c[:label] ||= data_class.human_attribute_name(c[:name])
          end

          def set_default_editor(c)
            c[:editor] ||= editor_for_attr_type(c[:attr_type])
            c[:editor] = {:xtype => c[:editor]} if c[:editor].is_a?(Symbol)
          end

          def set_default_width(c)
            c[:width] ||= 50 if c[:attr_type] == :boolean
            c[:width] ||= 150 if c[:attr_type] == :datetime
          end

          def set_default_hidden(c)
            c[:hidden] = true if primary_key_attr?(c) && c[:hidden].nil?
          end

          def set_default_editable(c)
            not_editable_if = primary_key_attr?(c)
            not_editable_if ||= c[:virtual]
            not_editable_if ||= c.delete(:read_only)

            editable_if = data_class.column_names.include?(c[:name])
            editable_if ||= data_class.instance_methods.map(&:to_s).include?("#{c[:name]}=")
            editable_if ||= association_attr?(c[:name])

            c[:editable] = editable_if && !not_editable_if if c[:editable].nil?
          end

          def set_default_sortable(c)
            c[:sortable] = !c[:virtual] if c[:sortable].nil?
          end

          def set_default_filterable(c)
            c[:filterable] = !c[:virtual] if c[:filterable].nil?
          end

          # Returns editor's xtype for a column type
          def editor_for_attr_type(type)
            attr_type_to_editor_map[type] || :textfield
          end

          def editor_for_association
            :combobox
          end

          # Returns a hash that maps a column type to the editor xtype. Override if you want different editors.
          def attr_type_to_editor_map
            {
              :integer => :numberfield,
              :boolean => :checkbox,
              :date => :datefield,
              :datetime => :xdatetime,
              :text => :textarea,
              :string => :textfield
            }
          end

          # Detects an association column and sets up the proper editor.
          def detect_association(c)
            # double-underscore notation? surely an association column
            if c[:name].index('__')
              assoc_name, assoc_method = c[:name].split('__')
              if assoc_method && assoc = data_class.reflect_on_association(assoc_name.to_sym)
                assoc_column = assoc.klass.columns_hash[assoc_method]
                assoc_method_type = assoc_column.try(:type)

                # if association column is boolean, display a checkbox (or alike), otherwise - a combobox (or alike)
                c[:editor] ||= assoc_method_type == :boolean ? editor_for_attr_type(:boolean) : editor_for_association
              end
            end
          end

          # Default fields that will be displayed in the Add/Edit/Search forms
          # You don't need to return normalized fields when overriding this method (for example, see BookGridWithVirtualAttributes)
          def default_fields_for_forms
            form_klass = "Netzke::ModelExtensions::#{config[:model]}ForFormPanel".constantize rescue nil
            form_klass ||= original_data_class

            # Select only those fields that are known to the form_klass
            selected_columns = columns.select do |c|
              form_klass.column_names.include?(c[:name]) ||
              form_klass.instance_methods.include?("#{c[:name]}=") ||
              association_attr?(c[:name])
            end

            selected_columns.map do |c|
              field_config = {:name => c[:name]}

              # scopes for combobox options
              field_config[:scopes] = c[:editor].is_a?(Hash) && c[:editor][:scopes]

              field_config
            end
          end

          def default_fields_for_forms_with_default_values
            default_fields_for_forms.map do |f|
              norm_attr = normalize_attr(f)
              attr_name = norm_attr[:name].to_sym
              norm_attr.merge(:value => norm_attr[:default_value] || columns_hash[attr_name].try(:fetch, :default_value, nil) || data_class.netzke_attribute_hash[attr_name].try(:fetch, :default_value, nil))
            end
          end

          # Receives 2 arrays of columns. Merges the missing config from the +source+ into +dest+, matching columns by name
          def reverse_merge_equally_named_columns(dest, source)
            dest.each{ |dc| dc.reverse_merge!(source.detect{ |sc| sc[:name] == dc[:name] } || {}) }
          end

      end
    end
  end
end
