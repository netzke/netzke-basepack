module Netzke
  module Basepack
    class SearchWindow < Netzke::Basepack::Window

      action :search do |a|
        a.text = I18n.t('netzke.basepack.search_window.actions.search')
      end

      action :cancel do |a|
        a.text = I18n.t('netzke.basepack.search_window.actions.cancel')
      end

      js_configure do |c|
        c.width = "50%"
        c.auto_height = true
        c.close_action = "hide"
        c.modal = true
        c.init_component = <<-JS
          function(){
            this.callParent();

            this.on('show', function(){
              this.closeRes = 'cancel';
            });
          }
        JS

        c.get_query = <<-JS
          function(){
            return this.items.first().getQuery();
          }
        JS

        c.on_search = <<-JS
          function(){
            this.closeRes = 'search';
            this.hide();
          }
        JS

        c.on_cancel = <<-JS
          function(){
            this.hide();
          }
        JS
      end

      def configure(c)
        super
        c.items = [:search_panel]
        c.title = I18n.t('netzke.basepack.search_window.title')
        c.persistence = false
        c.prevent_header = true
        c.buttons = [:search, :cancel]
      end

      component :search_panel do |c|
        c.klass = QueryBuilder
        c.model = config[:model]
        c.fields = config[:fields]
      end

    end
  end
end
