module Netzke
  module Basepack
    # == Configuration
    # +load_last_preset+ - on load, tries to load the latest saved preset
    class SearchPanel < Base

      include Netzke::Basepack::DataAccessor

      ATTRIBUTE_OPERATORS_MAP = {
        :integer => [
          ["eq", I18n.t('netzke.basepack.search_panel.equals')],
          ["gt", I18n.t('netzke.basepack.search_panel.greater_than')],
          ["lt", I18n.t('netzke.basepack.search_panel.less_than')]
        ],
        :text => [
          ["contains", I18n.t('netzke.basepack.search_panel.contains')] # same as matches => %string%
        ],
        :string => [
          ["contains", I18n.t('netzke.basepack.search_panel.contains')], # same as matches => %string%
          ["matches", I18n.t('netzke.basepack.search_panel.matches')]
        ],
        :boolean => [
          ["is_any", I18n.t('netzke.basepack.search_panel.is_true')],
          ["is_true", I18n.t('netzke.basepack.search_panel.is_true')],
          ["is_false", I18n.t('netzke.basepack.search_panel.is_false')]
        ],
        :date => [
          ["eq", I18n.t('netzke.basepack.search_panel.date_equals')],
          ["gt", I18n.t('netzke.basepack.search_panel.after')],
          ["lt", I18n.t('netzke.basepack.search_panel.before')],
          ["gteq", I18n.t('netzke.basepack.search_panel.on_or_after')],
          ["lteq", I18n.t('netzke.basepack.search_panel.on_or_before')]
        ],
        :datetime => [
          ["eq", I18n.t('netzke.basepack.search_panel.date_equals')],
          ["gt", I18n.t('netzke.basepack.search_panel.after')],
          ["lt", I18n.t('netzke.basepack.search_panel.before')],
          ["gteq", I18n.t('netzke.basepack.search_panel.on_or_after')],
          ["lteq", I18n.t('netzke.basepack.search_panel.on_or_before')]
        ]
      }

      js_configure do |c|
        c.extend = "Ext.form.FormPanel"
        c.padding = 5
        c.auto_scroll = true
        c.require :condition_field
        c.mixin
        c.attribute_operators_map = ATTRIBUTE_OPERATORS_MAP
      end

      def js_configure(c)
        super
        c.attrs = config[:fields]
        c.preset_query = (config[:load_last_preset] ? last_preset.try(:fetch, "query") : config[:query]) || []
      end

      def attributes
        config[:fields].map do |f|
          f[:attr_type] ||= :string
          {name: f[:name], field_label: f[:field_label], attr_type: f[:attr_type]}
        end
      end

      def last_preset
        (state[:presets] || []).last
      end

    end
  end
end
