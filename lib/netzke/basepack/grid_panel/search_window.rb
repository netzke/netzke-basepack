module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class SearchWindow < Netzke::Basepack::Window

        action :search
        action :cancel
        action :clear, :icon => :application_form
        
        js_properties :title => "Advanced Search", 
                      :width => "50%",
                      :auto_height => true,
                      :buttons => [:search.action, :cancel.action],
                      :tbar => [:clear.action]
        
        config :items => [js_component(:search_panel)]
        
        component :search_panel do
          {
            :class_name => "Basepack::SearchPanel", 
            :model => config[:model],
            :items => config[:fields]
          }
        end

        js_method :on_clear, <<-JS
          function(){
            this.items.first().getForm().reset();
          }
        JS

        js_method :on_search, <<-JS
          function(){
            this.conditions = this.items.first().getForm().getValues();
            
            // do not send values of empty values
            for (var cond in this.conditions) {
              if (this.conditions[cond] == "") delete this.conditions[cond];
            }
            
            this.closeRes = 'OK'; 
            this.close();
          }
        JS
        
        js_method :on_cancel, <<-JS
          function(){
            this.closeRes = 'cancel'; 
            this.close();
          }
        JS
        
      end
    end
  end
end