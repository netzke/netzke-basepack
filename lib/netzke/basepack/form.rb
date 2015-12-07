module Netzke
  module Basepack
    # Ext.form.Panel-based component
    #
    # == Netzke-specific config options
    #
    # * +model+ - name of the ActiveRecord model that provides data to this Grid.
    # * +record+ - record to be displayd in the form. Takes precedence over +:record_id+
    # * +record_id+ - id of the record to be displayd in the form. Also see +:record+
    # * +items+ - the layout of the fields as an array. See "Layout configuration".
    # * +mode+ - render mode, accepted options:
    # * +lockable+ - makes the form panel load initially in "display mode", then lets "unlock" it, change the values, and "lock" it again, while updating the values on the server
    # * +updateMask+ - +Ext.LoadMask+ config options for the mask shown while the form is submitting its values
    #
    # === Layout configuration
    #
    # The layout of the form is configured by supplying the +item+ config option, same way it would be configured in Ext (thus allowing for complex form layouts). Form will expand fields by looking at their names (unless +no_binding+ set to +true+ is specified for a specific field).
    #
    # == Endpoints
    # Form implements the following endpoints:
    #
    # * +load+ - loads a record with a given id from the server, e.g.:
    #
    #     someForm.server.load({id: 100});
    #
    # * +submit+ - gets called when the form gets submitted (e.g. by pressing the Apply button, or by calling onApply)
    # * +get_combobox_options+ - gets called when a 'remote' combobox field gets expanded
    class Form < Netzke::Base
      include self::Endpoints
      include self::Services
      include Netzke::Basepack::Fields
      include Netzke::Basepack::DataAccessor
      include Netzke::Core::ConfigToDslDelegator

      client_class do |c|
        c.extend = "Ext.form.Panel"
        c.require :readonly_mode
      end

      delegates_to_dsl :model, :record_id

      def configure_client(c)
        super

        configure_locked(c)
        configure_bbar(c)
        configure_apply_on_return(c)

        if data_adapter
          c.pri = data_adapter.primary_key
        end

        if !c.multi_edit
          c.record = js_record_data if record
        else
          c.record_id = c.record = nil if c.multi_edit # never set record_id in multi-edit mode
        end
      end

      action :apply do |a|
        a.icon = :tick
      end

      action :edit do |a|
        a.icon = :pencil
      end

      action :cancel do |a|
        a.icon = :cancel
      end

      def configure_locked(c)
        c[:locked] = c[:locked].nil? ? (c[:mode] == :lockable) : c[:locked]
      end

      def configure_bbar(c)
        c[:bbar] = ["->", :apply] if c[:bbar].nil? && !c[:read_only]
      end

      def configure_apply_on_return(c)
        c[:apply_on_return] = c[:apply_on_return].nil? ? true : !!c[:apply_on_return]
      end

      # Extra JavaScripts and stylesheets
      client_styles do |c|
        c.require :readonly_mode
      end

      # A hash of record data including the meta field
      def js_record_data
        data_adapter.record_to_hash(record, fields.values).merge(:meta => meta_field).netzke_literalize_keys
      end

      def record
        @record ||= config[:record] || config[:record_id] && data_adapter.find_record(config[:record_id])
      end

    protected

      def normalize_config
        config.items = items
        @fields_from_items = {} # will be built during execution of `super`
        super
      end

      def self.server_side_config_options
        super + [:scope]
      end

      def meta_field
        {}.tap do |res|
          assoc_values = get_association_values
          res[:association_values] = assoc_values.netzke_literalize_keys if record && !assoc_values.empty?
        end
      end

      def get_association_values
        fields_that_need_associated_values = fields.select{ |k,v| k.to_s.index("__") && !fields[k][:nested_attribute] }
        # Take care of Ruby 1.8.7
        if fields_that_need_associated_values.is_a?(Array)
          fields_that_need_associated_values = fields_that_need_associated_values.inject({}){|r,(k,v)| r.merge(k => v)}
        end

        fields_that_need_associated_values.each_pair.inject({}) do |r,(k,v)|
          r.merge(k => data_adapter.record_value_for_attribute(record, fields_that_need_associated_values[k], true))
        end
      end
    end
  end
end
