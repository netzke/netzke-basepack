class BookGridLoader < Netzke::Base
  js_property :layout, :fit

  component :book_grid_one, :class_name => "Netzke::Basepack::GridPanel", :model => "Book", :lazy_loading => true
  component :book_grid_two, :class_name => "Netzke::Basepack::GridPanel", :model => "Book", :lazy_loading => true

  action :load_one
  action :load_two

  js_method :on_load_one, <<-JS
    function(){
      this.loadComponent({name: 'book_grid_one', container: this.id});
    }
  JS

  js_method :on_load_two, <<-JS
    function(){
      this.loadComponent({name: 'book_grid_two', container: this.id});
    }
  JS

  js_property :bbar, [:load_one.action, :load_two.action]

end