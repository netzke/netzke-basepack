class SimplePanel < Netzke::Base
  action :update_html

  js_configure do |c|
    c.title = "SimplePanel"
    c.on_update_html = <<-JS
      function(){
        this.updateHtmlFromServer();
      }
    JS
  end

  def configure(c)
    c.html = "Original HTML"
    c.bbar = [:update_html]
    super
  end

  endpoint :update_html_from_server do |params, this|
    this[:update] = [config[:update_text] || "HTML received from server"]
  end
end
