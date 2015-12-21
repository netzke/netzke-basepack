class BookGridLoader < Netzke::Base
  component :book_grid_one do |c|
    c.klass = Netzke::Grid::Base
    c.model = "Book"
    c.title = "One"
  end

  component :book_grid_two do |c|
    c.klass = Netzke::Grid::Base
    c.model = "Book"
    c.title = "Two"
  end

  action :load_one
  action :load_two

  client_class do |c|
    c.layout = :fit

    c.on_load_one = <<-JS
      function(){
        this.netzkeLoadComponent('book_grid_one');
      }
    JS

    c.on_load_two = <<-JS
      function(){
        this.netzkeLoadComponent('book_grid_two');
      }
    JS
  end

  def configure(c)
    super
    c.bbar = [:load_one, :load_two]
  end
end
