module Netzke
  class SimplePanel < Widget::Panel
    def config
      {
        :title => "SimplePanel",
        :html => "Original HTML",
        :bbar => [:update_html]
      }.deep_merge(super)
    end
    
    api :update_html_from_server
    def update_html_from_server(params)
      {:update_body_html => "HTML received from server"}
    end
    
    def self.js_properties
      {
        :on_update_html => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.updateHtmlFromServer();
          }
        END_OF_JAVASCRIPT
      }
    end
  end
end