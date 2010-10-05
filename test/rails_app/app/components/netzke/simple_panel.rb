module Netzke
  class SimplePanel < Component::Panel
    def config
      {
        :title => "SimplePanel",
        :html => "Original HTML",
        :bbar => [:update_html.ext_action]
      }.deep_merge(super)
    end
  
    api :update_html_from_server
    def update_html_from_server(params)
      {:update_body_html => "HTML received from server"}
    end
  
    js_method :on_update_html, <<-JS
      function(){
        this.updateHtmlFromServer();
      }
    JS
  end
end