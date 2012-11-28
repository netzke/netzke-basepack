class WindowComponentLoader < Netzke::Base

  component :some_window do |c|
    c.persistence = true
    c.klass = Netzke::Basepack::Window
    c.title = "Some Window Component"
    c.width = 300
    c.height = 200
    c.x = 100
    c.y = 80
    c.modal = true
  end

  action :load_window

  def configure(c)
    super
    c.bbar = [:load_window]
  end

  js_configure do |c|
    c.on_load_window = <<-JS
      function(params){
        this.netzkeLoadComponent("some_window", {callback: function(w){
          w.show();
        }});
      }
    JS
  end

end
