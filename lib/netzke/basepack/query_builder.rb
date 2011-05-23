module Netzke
  module Basepack
    class QueryBuilder < Netzke::Base
      js_base_class "Ext.TabPanel"

      js_property :active_tab, 0

      js_translate :overwrite_confirm, :overwrite_confirm_title, :delete_confirm, :delete_confirm_title

      js_mixin :query_builder

      component :search_panel do
        {
          :class_name => "Netzke::Basepack::SearchPanel",
          :model => config[:model],
          :preset_query => config[:query],
          :auto_scroll => config[:auto_scroll]
        }
      end

      action :clear_all do
        {
          :text => I18n.t('netzke.basepack.query_builder.actions.clear_all'),
          :tooltip => I18n.t('netzke.basepack.query_builder.actions.clear_all_tooltip'),
          :icon => :cross
        }
      end

      action :reset do
        {
          :text => I18n.t('netzke.basepack.query_builder.actions.reset'),
          :tooltip => I18n.t('netzke.basepack.query_builder.actions.reset_tooltip'),
          :icon => :application_form
        }
      end

      action :save_preset do
        {
          :text => I18n.t('netzke.basepack.query_builder.actions.save_preset'),
          :tooltip => I18n.t('netzke.basepack.query_builder.actions.save_preset_tooltip'),
          :icon => :disk
        }
      end

      action :delete_preset do
        {
          :text => I18n.t('netzke.basepack.query_builder.actions.delete_preset'),
          :tooltip => I18n.t('netzke.basepack.query_builder.actions.delete_preset_tooltip'),
          :icon => :cross
        }
      end

      action :apply do
        {
          :text => I18n.t('netzke.basepack.query_builder.actions.apply'),
          :tooltip => I18n.t('netzke.basepack.query_builder.actions.apply_tooltip'),
          :icon => :accept
        }
      end

      def js_config
        super.tap do |s|
          s[:bbar] = (config[:bbar] || []) + [:clear_all.action, :reset.action, "->",
            I18n.t('netzke.basepack.query_builder.presets'),
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
        {:feedback => I18n.t('netzke.basepack.query_builder.preset_saved')}
      end

      endpoint :delete_preset do |params|
        saved_searches = state[:presets]
        saved_searches.delete_if{ |s| s["name"] == params[:name] }
        update_state(:presets, saved_searches)
        {:feedback => I18n.t('netzke.basepack.query_builder.preset_deleted')}
      end


    end
  end
end
