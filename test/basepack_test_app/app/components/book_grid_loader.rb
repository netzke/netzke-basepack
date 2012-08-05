class BookGridLoader < Netzke::Base
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

  js_configure do |c|
    c.layout = :fit

    c.on_load_one = <<-JS
      function(){
        this.loadNetzkeComponent({name: 'book_grid_one', container: this.id});
      }
    JS

    c.on_load_two = <<-JS
      function(){
        this.loadNetzkeComponent({name: 'book_grid_two', container: this.id});
      }
    JS
  end

  def configure(c)
    super
    c.bbar = [:load_one, :load_two]
  end
end
