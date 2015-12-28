class Grid::CustomRenderers < Netzke::Grid::Base
  column :author__first_name do |c|
    c.renderer = :uppercase
  end

  column :author__last_name do |c|
    c.renderer = :uppercase
  end

  column :title do |c|
    c.renderer = :my_renderer
  end

  def model
    Book
  end

  def columns
    [:author__first_name, :author__last_name, :title]
  end

  client_class do |c|
    c.my_renderer = <<-JS
      function(value){
        return value ? "*" + value + "*" : "";
      }
    JS
  end
end
