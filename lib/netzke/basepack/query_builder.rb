module Netzke
  module Basepack
    # Search query builder used in Grid's advanced search
    class QueryBuilder < Netzke::Base
      js_configure do |c|
        c.extend = "Ext.tab.Panel"
        c.active_tab = 0
        c.translate :overwrite_confirm, :overwrite_confirm_title, :delete_confirm, :delete_confirm_title
        c.mixin
      end

      component :search_panel do |c|
        c.klass = SearchPanel
        c.model = config[:model]
        c.fields = config[:fields]
        c.preset_query = config[:query]
        c.auto_scroll = config[:auto_scroll]
        c.eager_loading = true
      end

      action :clear_all do |a|
        a.text = I18n.t('netzke.basepack.query_builder.actions.clear_all')
        a.tooltip = I18n.t('netzke.basepack.query_builder.actions.clear_all_tooltip')
        a.icon = :cross
      end

      action :reset do |a|
        a.text = I18n.t('netzke.basepack.query_builder.actions.reset')
        a.tooltip = I18n.t('netzke.basepack.query_builder.actions.reset_tooltip')
        a.icon = :application_form
      end

      action :save_preset do |a|
        a.text = I18n.t('netzke.basepack.query_builder.actions.save_preset')
        a.tooltip = I18n.t('netzke.basepack.query_builder.actions.save_preset_tooltip')
        a.icon = :disk
      end

      action :delete_preset do |a|
        a.text = I18n.t('netzke.basepack.query_builder.actions.delete_preset')
        a.tooltip = I18n.t('netzke.basepack.query_builder.actions.delete_preset_tooltip')
        a.icon = :cross
      end

      action :apply do |a|
        a.text = I18n.t('netzke.basepack.query_builder.actions.apply')
        a.tooltip = I18n.t('netzke.basepack.query_builder.actions.apply_tooltip')
        a.icon = :accept
      end

      def js_configure(c)
        super
        c.preset_store = state[:presets].blank? ? [[[], ""]] : state[:presets].map{ |s| [s["query"], s["name"]] }
        c.bbar = (config[:bbar] || []) + [:clear_all, :reset, "->", I18n.t('netzke.basepack.query_builder.presets'), :preset_selector, :save_preset, :delete_preset ]
      end

      endpoint :save_preset do |params, this|
        saved_searches = state[:presets] || []
        existing = saved_searches.detect{ |s| s["name"] == params[:name] }
        query = ActiveSupport::JSON.decode(params[:query])
        if existing
          existing["query"].replace(query)
        else
          saved_searches << {"name" => params[:name], "query" => query}
        end
        state[:presets] = saved_searches
        this.netzke_feedback(I18n.t('netzke.basepack.query_builder.preset_saved'))
      end

      endpoint :delete_preset do |params, this|
        saved_searches = state[:presets]
        saved_searches.delete_if{ |s| s["name"] == params[:name] }
        state[:presets] = saved_searches
        this.netzke_feedback(I18n.t('netzke.basepack.query_builder.preset_deleted'))
      end
    end
  end
end
