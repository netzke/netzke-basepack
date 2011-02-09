module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class SearchWindow < Netzke::Basepack::Window

        action :search
        action :cancel

        js_properties :title => "Advanced Search",
                      :width => "50%",
                      :auto_height => true,
                      :close_action => "hide",
                      :buttons => [:search.action, :cancel.action],
                      :modal => true

        def configuration
          super.merge(:items => [:search_panel.component(:header => false)])
        end

        component :search_panel do
          {
            :class_name => "Netzke::Basepack::QueryBuilder",
            :model => config[:model]
          }
        end

        js_method :init_component, <<-JS
          function(){
            Netzke.classes.Basepack.GridPanel.SearchWindow.superclass.initComponent.call(this);

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
end
