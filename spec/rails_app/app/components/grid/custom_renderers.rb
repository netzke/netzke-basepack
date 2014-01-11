class Grid::CustomRenderers < Netzke::Basepack::Grid
  column :author__first_name do |c|
    c.renderer = :uppercase
  end

  column :author__last_name do |c|
    c.renderer = :uppercase
  end

  column :title do |c|
    c.renderer = :my_renderer
  end

  def configure(c)
    c.model = "Book"
    c.columns = [ :author__first_name, :author__last_name, :title]
    super
  end

  js_configure do |c|
    c.my_renderer = <<-JS
      function(value){
        return value ? "*" + value + "*" : "";
      }
    JS
  end
end
