require "netzke/basepack/form_panel/fields"
require "netzke/basepack/form_panel/services"
# require "netzke/plugins/configuration_tool"
# require "netzke/data_accessor"

module Netzke
  module Basepack
    # = FormPanel
    #
    # Represents Ext.form.FormPanel
    #
    # == Configuration
    # * <tt>:model</tt> - name of the ActiveRecord model that provides data to this GridPanel.
    # * <tt>:record</tt> - record to be displayd in the form. Takes precedence over <tt>:record_id</tt>
    # * <tt>:record_id</tt> - id of the record to be displayd in the form. Also see <tt>:record</tt>
    class FormPanel < Netzke::Base
      # Class-level configuration
      class_attribute :config_tool_available
      self.config_tool_available = true

      class_attribute :default_config
      self.default_config = {} # To be filled in

      include self::Services
      include self::Fields

      include Netzke::DataAccessor

      js_base_class "Netzke.pre.FormPanel"

      js_property :bbar, [:apply.action]

      # def initial_config
      #   res = super
      #   res[:bbar] = default_bbar if res[:bbar].nil?
      #   res
      # end
      #
      # def default_bbar
      #   [:apply.action]
      # end

      # Extra javascripts
      js_include "#{File.dirname(__FILE__)}/form_panel/javascripts/pre.js",
                  "#{File.dirname(__FILE__)}/form_panel/javascripts/xcheckbox.js"
          # Netzke::Base.config[:ext_location] + "/examples/ux/fileuploadfield/FileUploadField.js",
          # "#{File.dirname(__FILE__)}/form_panel/javascripts/netzkefileupload.js"

      def js_config
        super.merge(
          # :fields => fields,
          :pri    => data_class && data_class.primary_key
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

        action :apply, :text => I18n.t('netzke.basepack.form_panel.apply', :default => "Apply"), :icon => :tick

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