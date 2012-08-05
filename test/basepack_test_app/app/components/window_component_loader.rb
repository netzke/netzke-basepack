class WindowComponentLoader < Netzke::Base
  component :some_window do |c|
    c.persistence = true
    c.klass = Netzke::Basepack::Window
    c.title = "Some Window Component"
    c.width = 400
    c.height = 300
    c.modal = true
  end

  action :load_window

  def configure(c)
    super
    c.bbar = [:load_window]
  end

  js_method :on_load_window, <<-JS
    function(params){
      this.loadNetzkeComponent({name: "some_window", callback: function(w){
        w.show();
      }});
    }
  JS
end
