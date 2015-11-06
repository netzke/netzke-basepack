class Grid::CustomColumns < Netzke::Basepack::Grid
  column :author__first_name do |c|
    c.renderer = :my_renderer
    c.read_only = true
  end

  column :author__last_name do |c|
    c.renderer = :uppercase
    c.read_only = true
  end

  column :author__name do |c|
    c.flex = 1
    c.sorting_scope = :sorted_by_author_name
    c.text = "Author"
  end

  column :title do |c|
    c.flex = 1
  end

  column :extra_column do |c|
    c.text = "Extra"
  end

  column :rating do |c|
    c.editor = {
      :trigger_action => :all,
      :xtype => :combo,
      :store => [[1, "Good"], [2, "Average"], [3, "Poor"]]
    }

    c.renderer = "function(v){return ['', 'Good', 'Average', 'Poor'][v];}"
  end

  def configure(c)
    c.model = "Book"
    c.columns = [ :author__first_name, :author__last_name, :author__name, :title, :digitized, :rating, :exemplars, :updated_at ]
    super
  end

  # This way we'll always have the extra_column, independent of the columns provided in the configuration
  def columns
    super + [:extra_column]
  end

  client_class do |c|
    c.my_renderer = <<-JS
      function(value){
        return value ? "*" + value + "*" : "";
      }
    JS
  end
end
