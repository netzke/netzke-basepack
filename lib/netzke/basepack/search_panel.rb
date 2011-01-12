module Netzke
  module Basepack
    # == Configuration
    # +load_last_preset+ - on load, tries to load the latest saved preset
    class SearchPanel < Base

      js_base_class "Ext.form.FormPanel"

      js_properties(
        :header => false,
        :padding => 5
      )

      js_include :condition_field

      js_mixin :main

      js_property :attribute_operators_map, {
        :integer => [
          ["eq", I18n.t('netzke.basepack.search_panel.equals')],
          ["gt", I18n.t('netzke.basepack.search_panel.greater_than')],
          ["lt", I18n.t('netzke.basepack.search_panel.less_than')]
        ],
        :string => [
          ["contains", I18n.t('netzke.basepack.search_panel.contains')], # same as matches => %string%
          ["matches", I18n.t('netzke.basepack.search_panel.matches')]
        ],
        :boolean => [
          # TODO: add ["any", "Any"],
          ["is_true", I18n.t('netzke.basepack.search_panel.yes')],
          ["is_false", I18n.t('netzke.basepack.search_panel.no')]
        ],
        :datetime => [
          ["eq", I18n.t('netzke.basepack.search_panel.on')],
          ["gt", I18n.t('netzke.basepack.search_panel.after')],
          ["lt", I18n.t('netzke.basepack.search_panel.before')]
        ]
      }

      action :clear_all, :icon => :cross
      action :add_condition, :icon => :add

      action :save_preset, :icon => :disk
      action :delete_preset, :icon => :cross

      def default_query
        data_class.column_names.map do |c|
          column_type = data_class.columns_hash[c].type
          operator = (self.class.js_property(:attribute_operators_map)[column_type] || []).first.try(:fetch, 0) || "matches"
          {:attr => c, :attr_type => column_type, :operator => operator}
        end
      end

      def data_class
        @data_class ||= config[:model].constantize
      end

      def js_config
        super.merge(
          :attrs => data_class.column_names,
          :attrs_hash => data_class.column_names.inject({}){ |hsh,c| hsh.merge(c => data_class.columns_hash[c].type) },
          :query => (config[:load_last_preset] ? last_preset.try(:fetch, "query") : config[:query]) || default_query,
          :bbar => [:add_condition.action, :clear_all.action, "->",
            I18n.t('netzke.basepack.search_panel.presets'),
            {
              :xtype => "combo",
              :triggerAction => "all",
              :value => super[:load_last_preset] && last_preset.try(:fetch, "name"),
              :store => state[:presets].blank? ? [[[], ""]] : state[:presets].map{ |s| [s["query"], s["name"]] },
              :ref => "../presetsCombo",
              :listeners => {:before_select => {
                :fn => "function(combo, record){
                  var form = Ext.getCmp('#{global_id}');
                  form.removeAll();
                  form.buildFormFromQuery(record.data.field1);
                }".l
              }}
            }, :save_preset.action, :delete_preset.action
          ]
        )
      end

      def last_preset
        (state[:presets] || []).last
      end

      js_method :init_component, <<-JS
        function(){
          Netzke.classes.Basepack.SearchPanel.superclass.initComponent.call(this);
          this.buildFormFromQuery(this.query);
        }
      JS

      js_method :build_form_from_query, <<-JS
        // Will probably need to be performance-optimized in the future, as recreating the fields is expensive
        function(query){
          Ext.each(query, function(f){
            this.add(Ext.apply(f, {xtype: 'netzkebasepacknewsearchpanelconditionfield'}));
          }, this);
          this.doLayout();
        }
      JS


      js_method :on_add_condition, <<-JS
        function(){
          this.add({xtype: 'netzkebasepacknewsearchpanelconditionfield'});
          this.doLayout();
        }
      JS

      js_method :on_clear_all, <<-JS
        function(){
          this.removeAll();
        }
      JS

      js_method :get_query, <<-JS
        function(all){
          var query = [];
          this.items.each(function(f){
            if (f.valueIsSet() || all) {
              var cond = f.buildValue();
              if (all) {cond.attrType = f.attrType;}
              query.push(cond);
            }
          });
          return query;
        }
      JS

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
