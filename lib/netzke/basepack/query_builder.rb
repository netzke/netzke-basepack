module Netzke
  module Basepack
    # Search query builder used in Grid's advanced search.
    # Based on Ext.tab.Panel. A new tab is created for each OR condition. Each tab contains an instance of SearchPanel which is used to build AND conditions.
    class QueryBuilder < Netzke::Base
      client_class do |c|
        c.extend = "Ext.tab.Panel"
        c.active_tab = 0
        c.translate :overwrite_confirm, :overwrite_confirm_title, :delete_confirm, :delete_confirm_title
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
        a.icon = :cross
      end

      action :reset do |a|
        a.icon = :application_form
      end

      action :save_preset do |a|
        a.icon = :disk
      end

      action :delete_preset do |a|
        a.icon = :cross
      end

      action :apply do |a|
        a.icon = :accept
      end

      def configure_client(c)
        super
        c.preset_store = state[:presets].blank? ? [[[], ""]] : state[:presets].map{ |s| [s["query"], s["name"]] }
        c.bbar = (config[:bbar] || []) + [:clear_all, :reset, "->", I18n.t('netzke.basepack.query_builder.presets'), :preset_selector, :save_preset, :delete_preset ]
      end

      endpoint :save_preset do |params|
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

      endpoint :delete_preset do |params|
        saved_searches = state[:presets]
        saved_searches.delete_if{ |s| s["name"] == params[:name] }
        state[:presets] = saved_searches
        this.netzke_feedback(I18n.t('netzke.basepack.query_builder.preset_deleted'))
      end
    end
  end
end
