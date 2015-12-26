class WindowComponentLoader < Netzke::Base
  component :some_window do |c|
    c.persistence = true
    c.klass = Netzke::Window::Base
    c.title = "Some Window Component"
    c.width = 300
    c.height = 200
    c.x = 100
    c.y = 80
    c.modal = true
  end

  action :load_window
  action :reset_session

  def configure(c)
    super
    c.bbar = [:load_window, :reset_session]
  end

  client_class do |c|
    c.netzke_on_load_window = <<-JS
      function(params){
        this.netzkeLoadComponent("some_window", {callback: function(w){
          w.show();
        }});
      }
    JS

    c.netzke_on_reset_session = <<-JS
      function(params){
        this.server.resetSession();
      }
    JS
  end

  endpoint :reset_session do
    component_instance(:some_window).state.clear
  end
end
