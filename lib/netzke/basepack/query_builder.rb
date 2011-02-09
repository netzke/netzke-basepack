module Netzke
  module Basepack
    class QueryBuilder < Netzke::Base
      js_base_class "Ext.TabPanel"
      js_property :active_tab, 0

      js_mixin :query_builder

      component :search_panel do
        {
          :class_name => "Netzke::Basepack::SearchPanel",
          :model => config[:model],
          :query => config[:query],
          :auto_scroll => config[:auto_scroll]
        }
      end

      action :clear_all, :icon => :cross
      action :reset, :icon => :application_form

      action :save_preset, :icon => :disk
      action :delete_preset, :icon => :cross

      action :apply, :icon => :accept

      def js_config
        super.tap do |s|
          s[:bbar] = (config[:bbar] || []) + [:clear_all.action, :reset.action, "->",
            I18n.t('netzke.basepack.query_builder.presets', :default => "Presets"),
            {
              :xtype => "combo",
              :triggerAction => "all",
              :value => super[:load_last_preset] && last_preset.try(:fetch, "name"),
              :store => state[:presets].blank? ? [[[], ""]] : state[:presets].map{ |s| [s["query"], s["name"]] },
              :ref => "../presetsCombo",
              :listeners => {:before_select => {
                :fn => "function(combo, record){
                  var form = Ext.getCmp('#{global_id}');
                  form.buildFormFromQuery(record.data.field1);
                }".l
              }}
            }, :save_preset.action, :delete_preset.action
          ]
        end
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
        update_state(:presets, saved_searches)
        {:feedback => I18n.t('netzke.basepack.search_panel.preset_saved')}
      end

      endpoint :delete_preset do |params|
        saved_searches = state[:presets]
        saved_searches.delete_if{ |s| s["name"] == params[:name] }
        update_state(:presets, saved_searches)
        {:feedback => I18n.t('netzke.basepack.search_panel.preset_deleted')}
      end


    end
  end
end
