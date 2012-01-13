class WindowComponentLoader < Netzke::Base
  component :some_window, {
    :persistence => true,
    :class_name => "Netzke::Basepack::Window",
    :title => "Some Window Component",
    :lazy_loading => true,
    :width => 400,
    :height => 300,
    :modal => true,
    :items => [{
      :class_name => "Netzke::Basepack::GridPanel",
      :model => "User"
    }]
  }

  action :load_window

  js_property :bbar, [:load_window.action]

  js_method :on_load_window, <<-JS
    function(params){
      this.loadNetzkeComponent({name: "some_window", callback: function(w){
        w.show();
      }});
    }
  JS
end
