module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class SearchWindow < Netzke::Basepack::Window

        action :search
        action :cancel
        action :clear, :icon => :application_form
        
        js_properties :title => "Advanced Search", 
                      :width => "Ext.lib.Dom.getViewWidth() *0.9".l,
                      :height => "Ext.lib.Dom.getViewHeight() *0.9".l,
                      :buttons => [:search.action, :cancel.action],
                      :tbar => [:clear.action]
        
        def config
          orig = super
          
          orig.merge(
            :items => [{
              :class_name => "Basepack::SearchPanel", 
              :model => orig[:model],
              :items => orig[:fields]
            }]
          )
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