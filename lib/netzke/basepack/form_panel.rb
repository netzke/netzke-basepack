require "netzke/basepack/form_panel/fields"
require "netzke/basepack/form_panel/services"
require "netzke/data_accessor"
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

      # Class-level configuration
      class_attribute :config_tool_available
      self.config_tool_available = true

      class_attribute :default_config
      self.default_config = {} # To be filled in

      include self::Services
      include self::Fields
      include Netzke::DataAccessor

      js_base_class "Ext.form.FormPanel"

      def bbar(config)
        config[:mode] == :lockable ? nil : [:apply.action]
      end

      action :apply, :text => I18n.t('netzke.basepack.form_panel.apply', :default => "Apply"), :icon => :tick
      action :edit, :text => I18n.t('netzke.basepack.form_panel.edit', :default => "Edit"), :icon => :pencil
      action :cancel, :text => I18n.t('netzke.basepack.form_panel.cancel', :default => "Cancel"), :icon => :cancel

      def configuration
        sup = super

        sup.merge(
          :bbar => sup[:bbar] || bbar(sup),
          :locked => sup[:locked].nil? ? (sup[:mode] == :lockable) : sup[:locked]
        )
      end

      # Extra javascripts
      js_mixin :main
      js_include :comma_list_cbg
      js_include :n_radio_group, :display_mode
      # Netzke::Base.config[:ext_location] + "/examples/ux/fileuploadfield/FileUploadField.js",
      # "#{File.dirname(__FILE__)}/form_panel/javascripts/netzkefileupload.js"

      def js_config
        super.merge(
          :pri    => data_class && data_class.primary_key,
          :fields => fields
        )
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
            # {:name => "ext_config__title",               :attr_type => :string},
            # {:name => "ext_config__header",              :attr_type => :boolean, :default => true},
            # {:name => "ext_config__bbar",              :attr_type => :json}
          ]

          res
        end

        private

          def self.server_side_config_options
            super + [:record]
          end

      # include ::Netzke::Plugins::ConfigurationTool if config_tool_available # it will load ConfigurationPanel into a modal window
    end
  end
end
