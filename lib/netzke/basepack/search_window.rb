module Netzke
  module Basepack
    class SearchWindow < Netzke::Basepack::Window

      action :search do
        {:text => I18n.t('netzke.basepack.search_window.actions.search')}
      end

      action :cancel do
        {:text => I18n.t('netzke.basepack.search_window.actions.cancel')}
      end

      js_properties :width => "50%",
                    :auto_height => true,
                    :close_action => "hide",
                    :buttons => [:search.action, :cancel.action],
                    :modal => true

      def configuration
        super.tap do |s|
          s[:items] = [:search_panel.component(:header => false)]
          s[:title] = I18n.t('netzke.basepack.search_window.title')
        end
      end

      component :search_panel do
        {
            :class_name => "Netzke::Basepack::QueryBuilder",
            :model => config[:model],
            :model_columns => config[:model_columns]
        }
      end

      js_method :init_component, <<-JS
        function(){
          Netzke.classes.Basepack.SearchWindow.superclass.initComponent.call(this);

          this.on('show', function(){
            this.closeRes = 'cancel';
          });
        }
      JS

      js_method :get_query, <<-JS
        function(){
          return this.items.first().getQuery();
        }
      JS

      js_method :on_search, <<-JS
        function(){
          this.closeRes = 'search';
          this.hide();
        }
      JS

      js_method :on_cancel, <<-JS
        function(){
          this.hide();
        }
      JS

    end
  end
end
