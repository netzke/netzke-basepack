require "netzke/basepack/form_panel/fields"
require "netzke/basepack/form_panel/services"
# require "netzke/plugins/configuration_tool"

module Netzke
  module Basepack
    # Ext.form.Panel-based component
    #
    # == Netzke-specific config options
    #
    # * +model+ - name of the ActiveRecord model that provides data to this GridPanel.
    # * +record+ - record to be displayd in the form. Takes precedence over +:record_id+
    # * +record_id+ - id of the record to be displayd in the form. Also see +:record+
    # * +items+ - the layout of the fields as an array. See "Layout configuration".
    # * +mode+ - render mode, accepted options:
    #   * +lockable+ - makes the form panel load initially in "display mode", then lets "unlock" it, change the values, and "lock" it again, while updating the values on the server
    # * +updateMask+ - +Ext.LoadMask+ config options for the mask shown while the form is submitting its values
    #
    # === Layout configuration
    #
    # The layout of the form is configured by supplying the +item+ config option, same way it would be configured in Ext (thus allowing for complex form layouts). FormPanel will expand fields by looking at their names (unless +no_binding+ set to +true+ is specified for a specific field).
    #
    # == Endpoints
    # FormPanel implements the following endpoints:
    #
    # * +netzke_load+ - loads a record with a given id from the server, e.g.:
    #
    #     someFormPanel.netzkeLoad({id: 100});
    #
    # * +netzke_submit+ - gets called when the form gets submitted (e.g. by pressing the Apply button, or by calling onApply)
    # * +get_combobox_options+ - gets called when a 'remote' combobox field gets expanded
    class FormPanel < Netzke::Base
      include self::Services
      include self::Fields
      include Netzke::Basepack::DataAccessor
      include Netzke::ConfigToDslDelegator

      js_configure do |c|
        c.extend = "Ext.form.Panel"
        c.mixin
        c.include :comma_list_cbg, :n_radio_group, :readonly_mode
      end

      delegates_to_dsl :model, :record_id

      def js_configure(c)
        super

        configure_locked(c)
        configure_bbar(c)

        # prepend the primary key field if not present
        if data_adapter
          c.items = [extend_item(data_adapter.primary_key_name.to_sym), *c.items] if !includes_primary_key_field?(c.items)
          c.pri = data_adapter.primary_key_name
        end

        if !c.multi_edit
          c.record = js_record_data if record
        else
          c.record_id = c.record = nil if c.multi_edit # never set record_id in multi-edit mode
        end
      end

      action :apply do |a|
        a.text = I18n.t('netzke.basepack.form_panel.actions.apply')
        a.tooltip = I18n.t('netzke.basepack.form_panel.actions.apply_tooltip')
        a.icon = :tick
      end

      action :edit do |a|
        a.text = I18n.t('netzke.basepack.form_panel.actions.edit')
        a.tooltip = I18n.t('netzke.basepack.form_panel.actions.edit_tooltip')
        a.icon = :pencil
      end

      action :cancel do |a|
        a.text = I18n.t('netzke.basepack.form_panel.actions.cancel')
        a.tooltip = I18n.t('netzke.basepack.form_panel.actions.cancel_tooltip')
        a.icon = :cancel
      end

      def configure_locked(c)
        c[:locked] = c[:locked].nil? ? (c[:mode] == :lockable) : c[:locked]
      end

      def configure_bbar(c)
        c[:bbar] = [:apply] if c[:bbar].nil? && !c[:read_only]
      end

      # Extra JavaScripts and stylesheets
      css_configure do |c|
        c.include :readonly_mode
      end

      # A hash of record data including the meta field
      def js_record_data
        record.netzke_hash(fields).merge(:_meta => meta_field).literalize_keys
      end

      def record
        @record ||= config[:record] || config[:record_id] && data_adapter && data_adapter.find_record(config[:record_id])
      end

    protected

      def includes_primary_key_field?(items)
        !!items.detect do |item|
          (item.is_a?(Hash) ? item[:name] : item.to_s) == data_adapter.primary_key_name
        end
      end

      def normalize_config
        config.items ||= default_items
        @fields_from_config = {}
        super
      end

      def self.server_side_config_options
        super + [:scope]
      end

      def meta_field
        {}.tap do |res|
          assoc_values = get_association_values
          res[:association_values] = assoc_values.literalize_keys if record && !assoc_values.empty?
        end
      end

      def get_association_values
        fields_that_need_associated_values = fields.select{ |k,v| k.to_s.index("__") && !fields[k][:nested_attribute] }
        # Take care of Ruby 1.8.7
        if fields_that_need_associated_values.is_a?(Array)
          fields_that_need_associated_values = fields_that_need_associated_values.inject({}){|r,(k,v)| r.merge(k => v)}
        end

        fields_that_need_associated_values.each_pair.inject({}) do |r,(k,v)|
          r.merge(k => record.value_for_attribute(fields_that_need_associated_values[k], true))
        end
      end
    end
  end
end
