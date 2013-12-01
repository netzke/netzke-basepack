module Grid
  class InTabs < Netzke::Basepack::TabPanel
    component :grid_one do |c|
      c.klass = BookGrid
      c.title = 'One'
    end

    component :grid_two do |c|
      c.klass = BookGrid
      c.eager_loading = true
      c.title = 'Two'
    end

    def configure(c)
      super
      c.items = [:grid_one, :grid_two]
    end
  end
end
