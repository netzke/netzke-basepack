module Netzke
  module Basepack
    # Takes care of automatic column configuration in {Basepack::Grid}
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

      def set_defaults!
        super

        self.attr_type ||= @data_adapter.attr_type(name)

        set_xtype! if xtype.nil?

        self.virtual = @data_adapter.virtual_attribute?(self)

        self.text ||= label || @data_adapter.human_attribute_name(name)

        set_editor! if editor.nil?

        set_width! if width.nil?

        self.hidden = primary? if hidden.nil?

        self.sortable = !virtual || !sorting_scope.nil? if sortable.nil?

        self.filterable = !virtual || !filter_with.nil? if filterable.nil?

        self.assoc = association? # used at the JS side

        remove_defaults! # options that are implied by Ext JS by default, thus don't have to be passed
      end

      def set_xtype!
        # if user set those manually, we don't mess with column xtype
        return if renderer || editor
        xtype = xtype_for_attr_type(attr_type)
        self.xtype = xtype unless xtype.nil?
      end

      def xtype_for_attr_type(type)
        { :boolean  => :checkcolumn,
          :date     => :datecolumn
        }[type]
      end

      def set_editor!
        # if shouldn't be editable, don't set any default editor
        return if read_only

        if association?
          set_default_association_editor!
        else
          self.editor ||= editor_for_attr_type(attr_type)
        end
      end

      # Detects an association column and sets up the proper editor.
      def set_default_association_editor!
        assoc, assoc_method = name.split('__')

        assoc_method_type = @data_adapter.get_assoc_property_type assoc, assoc_method

        # if association column is boolean, display a checkbox (or alike), otherwise - a combobox (or alike)
        if nested_attribute
          self.editor ||= editor_for_attr_type(assoc_method_type)
        else
          self.editor ||= assoc_method_type == :boolean ? editor_for_attr_type(:boolean) : {xtype: :netzkeremotecombo}
        end
      end

      # Column editor config for attribute type.
      def editor_for_attr_type(type)
        {xtype: attr_type_to_editor_xtype_map(type)}
      end

      # Hash that maps a column type to the editor xtype. Override if you want different editors.
      def attr_type_to_editor_xtype_map(type)
        { :integer => :numberfield,
          :boolean => :checkbox,
          :date => :datefield,
          :datetime => :xdatetime,
          :text => :textarea,
          :string => :textfield
        }[type] || :textfield
      end

      def set_width!
        self.width = case attr_type
        when :boolean
          50
        when :datetime
          150
        else
          100
        end
      end

      ##
      # @return self
      def remove_defaults!
        COMMON_DEFAULTS.each_pair {|k,v| self.delete(k) if v == self[k]}
        self
      end
    end
  end
end
