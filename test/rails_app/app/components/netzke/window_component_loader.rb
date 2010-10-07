module Netzke
  class WindowComponentLoader < Base
    component :some_window, {
      :class_name => "Basepack::Window",
      :title => "Some Window Component",
      :lazy_loading => true
    }
    
    js_property :bbar, [:load_window.action]
    
    js_method :on_load_window, <<-JS
      function(params){
        this.loadComponent({name: "some_window"});
      }
    JS
  end
end