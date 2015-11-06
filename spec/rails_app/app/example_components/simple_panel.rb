class SimplePanel < Netzke::Base
  action :update_html

  client_class do |c|
    c.title = "SimplePanel"
    c.on_update_html = <<-JS
      function(){
        this.updateHtmlFromServer();
      }
    JS
  end

  def configure(c)
    c.bbar = [:update_html]
    super
  end

  def self.server_side_config_options
    super << :update_text
  end

  endpoint :update_html_from_server do |params|
    this.set_title(config[:update_text] || "HTML received from server")
  end
end
