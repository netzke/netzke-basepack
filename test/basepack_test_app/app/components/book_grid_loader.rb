class BookGridLoader < Netzke::Base
  js_property :layout, :fit

  component :book_grid_one do |c|
    c.klass = Netzke::Basepack::GridPanel
    c.model = "Book"
    c.title = "One"
  end

  component :book_grid_two do |c|
    c.klass = Netzke::Basepack::GridPanel
    c.model = "Book"
    c.title = "Two"
  end

  action :load_one
  action :load_two

  js_method :on_load_one, <<-JS
    function(){
      this.loadNetzkeComponent({name: 'book_grid_one', container: this.id});
    }
  JS

  js_method :on_load_two, <<-JS
    function(){
      this.loadNetzkeComponent({name: 'book_grid_two', container: this.id});
    }
  JS

  def configure
    super
    config.bbar = [:load_one, :load_two]
  end
end
