module Netzke
  module Basepack
    # Takes care of automatic column configuration in {Grid::Base}
    class ColumnConfig < AttrConfig
      # These config options can be ommitted from config, as they are assumed by default at the JS side
      COMMON_DEFAULTS = {
        virtual: false,
        sortable: true,
        filterable: true,
        width: 100,
        hidden: false,
        assoc: false
      }

      def merge_attribute(attr)
        self.merge!(attr)

        self.text = delete(:label) if self.has_key?(:label)

        self.merge!(delete(:column_config)) if self.has_key?(:column_config)

        self.delete(:field_config) if self.has_key?(:field_config)
      end

      def set_defaults
        super

        self.type ||= @model_adapter.attr_type(name)

        set_xtype if xtype.nil?

        self.virtual = @model_adapter.virtual_attribute?(self)

        self.text ||= label || default_label

        set_editor

        set_width if width.nil?

        self.hidden = primary? if hidden.nil?

        self.sortable = !virtual || !sorting_scope.nil? if sortable.nil?

        self.filterable = !virtual || !filter_with.nil? if filterable.nil?

        self.assoc = association? # used at the JS side

        remove_defaults # options that are implied by Ext JS by default, thus don't have to be passed
      end

      def set_xtype
        # if user set those manually, we don't mess with column xtype
        return if renderer || editor
        xtype = xtype_for_type(type)
        self.xtype = xtype unless xtype.nil?
      end

      def xtype_for_type(type)
        { :boolean  => :checkcolumn,
          :date     => :datecolumn
        }[type]
      end

      def set_editor
        # if shouldn't be editable, don't set any default editor
        return if read_only

        passed_editor = editor

        if association?
          set_default_association_editor
        else
          self.editor = editor_for_type(type)
        end

        self.editor.merge!(passed_editor) if passed_editor
      end

      # Detects an association column and sets up the proper editor.
      def set_default_association_editor
        assoc, assoc_method = name.split('__')

        assoc_method_type = @model_adapter.get_assoc_property_type assoc, assoc_method

        # if association column is boolean, display a checkbox (or alike), otherwise - a combobox (or alike)
        if nested_attribute
          self.editor = editor_for_type(assoc_method_type)
        else
          self.editor = assoc_method_type == :boolean ? editor_for_type(:boolean) : {xtype: :netzkeremotecombo}
        end
      end

      # Column editor config for attribute type.
      def editor_for_type(type)
        {xtype: type_to_editor_xtype(type)}
      end

      def type_to_editor_xtype(type)
        type_to_editor_xtype_map[type] || :textfield
      end

      # Hash that maps a column type to the editor xtype. Override if you want different editors.
      def type_to_editor_xtype_map
        {
          integer: :numberfield,
          boolean: :checkbox,
          date: :datefield,
          datetime: :xdatetime,
          text: :textarea,
          string: :textfield
        }
      end

      def set_width
        self.width = 150 if type == :datetime
      end

      ##
      # @return self
      def remove_defaults
        COMMON_DEFAULTS.each_pair {|k,v| self.delete(k) if v == self[k]}
        self
      end
    end
  end
end
