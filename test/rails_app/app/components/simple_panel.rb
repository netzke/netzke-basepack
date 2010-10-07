class SimplePanel < Netzke::Basepack::Panel
  def config
    {
      :title => "SimplePanel",
      :html => "Original HTML",
      :bbar => [:update_html.action]
    }.deep_merge(super)
  end

  endpoint :update_html_from_server do |params|
    {:update_body_html => "HTML received from server"}
  end

  js_method :on_update_html, <<-JS
    function(){
      this.updateHtmlFromServer();
    }
  JS
end
