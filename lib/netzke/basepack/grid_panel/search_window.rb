module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class SearchWindow < Netzke::Basepack::Window

        action :search
        action :cancel

        js_properties :title => "Advanced Search",
                      :width => "50%",
                      :auto_height => true,
                      :buttons => [:search.action, :cancel.action],
                      :modal => true

        def configuration
          super.merge(:items => [:search_panel.component(:header => false)])
        end

        component :search_panel do
          {
            :class_name => "Netzke::Basepack::SearchPanel",
            :model => config[:model]
          }
        end

        js_method :on_search, <<-JS
          function(){
            this.query = this.items.first().getQuery();

            this.closeRes = 'OK';
            this.hide();
          }
        JS

        js_method :on_cancel, <<-JS
          function(){
            this.closeRes = 'cancel';
            this.hide();
          }
        JS

      end
    end
  end
end
