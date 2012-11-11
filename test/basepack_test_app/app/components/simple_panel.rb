class SimplePanel < Netzke::Base
  action :update_html

  js_configure do |c|
    c.title = "SimplePanel"
    c.html = "Original HTML"
    c.on_update_html = <<-JS
      function(){
        this.updateHtmlFromServer();
      }
    JS
    c.update_body_html = <<-JS
      function(){
        this.body.update(html);
      }
    JS
  end

  def configure(c)
    super
    c.bbar = [:update_html]
  end

  endpoint :update_html_from_server do |params, this|
    this.update_body_html config[:update_text] || "HTML received from server"
  end

end
