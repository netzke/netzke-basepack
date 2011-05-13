require "netzke/basepack/form_panel/fields"
require "netzke/basepack/form_panel/services"
# require "netzke/plugins/configuration_tool"

module Netzke
  module Basepack
    # Ext.form.FormPanel-based component with different goodies
    #
    # == Configuration
    # Besides all the standard +Ext.form.FormPanel+ config options, accepts:
    # * +model+ - name of the ActiveRecord model that provides data to this GridPanel.
    # * +record+ - record to be displayd in the form. Takes precedence over +:record_id+
    # * +record_id+ - id of the record to be displayd in the form. Also see +:record+
    # * +mode+ - render mode, accepted options:
    #   * +lockable+ - makes the form panel load initially in "display mode", then lets "unlock" it, change the values, and "lock" it again, while updating the values on the server
    # * +updateMask+ - +Ext.LoadMask+ config options for the mask shown while the form is submitting its values
    #
    # === Layout configuration
    # The layout of the form is configured by supplying the +item+ config option, same way it would be configured in Ext (thus allowing for complex form layouts). FormPanel will expand fields by looking at their names (unless +no_binding+ set to +true+ is specified for a specific field).
    class FormPanel < Netzke::Base

      js_base_class "Ext.form.Panel"

      # Class-level configuration
      class_attribute :config_tool_available
      self.config_tool_available = true

      class_attribute :default_config
      self.default_config = {} # To be filled in

      include self::Services
      include self::Fields
      include Netzke::Basepack::DataAccessor

      action :apply do
        {
          :text => I18n.t('netzke.basepack.form_panel.actions.apply'),
          :tooltip => I18n.t('netzke.basepack.form_panel.actions.apply_tooltip'),
          :icon => :tick
        }
      end

      action :edit do
        {
          :text => I18n.t('netzke.basepack.form_panel.actions.edit'),
          :tooltip => I18n.t('netzke.basepack.form_panel.actions.edit_tooltip'),
          :icon => :pencil
        }
      end

      action :cancel do
        {
          :text => I18n.t('netzke.basepack.form_panel.actions.cancel'),
          :tooltip => I18n.t('netzke.basepack.form_panel.actions.cancel_tooltip'),
          :icon => :cancel
        }
      end

      def configuration
        super.tap do |sup|
          configure_locked(sup)
          configure_bbar(sup)
        end
      end

      def configure_locked(c)
        c[:locked] = c[:locked].nil? ? (c[:mode] == :lockable) : c[:locked]
      end

      def configure_bbar(c)
        c[:bbar] = [:apply.action] if c[:bbar].nil?
      end

      # Extra JavaScripts and stylesheets
      js_mixin :form_panel
      # js_include :comma_list_cbg
      # js_include :n_radio_group, :readonly_mode
      css_include :readonly_mode

      # js_include Netzke::Core.ext_path.join("examples/ux/fileuploadfield/FileUploadField.js")
      # css_include Netzke::Core.ext_path.join("examples/ux/fileuploadfield/css/fileuploadfield.css")

      # js_include :misc

      def js_config
        super.tap do |res|
          res[:pri] = data_class && data_class.primary_key
          res[:record] = js_record_data if record
        end
      end

      # A hash of record data including the meta field
      def js_record_data
        record.to_hash(fields).merge(:_meta => meta_field).literalize_keys
      end

      def record
        @record ||= config[:record] || config[:record_id] && data_class && data_class.where(data_class.primary_key => config[:record_id]).first
      end

      def configuration_components
        res = []

          res << {
            :name              => 'fields',
            :class_name => "FieldsConfigurator",
            :active            => true,
            :owner             => self,
            :persistent_config => true
          }

          res << {
            :name               => 'general',
            :class_name  => "PropertyEditor",
            :component             => self,
            :title => false
          }

          res
        end

        def self.property_fields
          res = [
            {:name => "ext_config__title",               :attr_type => :string},
            {:name => "ext_config__header",              :attr_type => :boolean, :default => true},
            {:name => "ext_config__bbar",              :attr_type => :json}
          ]

          res
        end

        private

          def self.server_side_config_options
            super + [:record, :scope]
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

      # include ::Netzke::Plugins::ConfigurationTool if config_tool_available # it will load ConfigurationPanel into a modal window
    end
  end
end
