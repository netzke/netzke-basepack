module Grid
  class InTabs < Netzke::Base
    client_class do |c|
      c.extend = "Ext.tab.Panel"
    end

    component :grid_one do |c|
      c.klass = Grid::Books
      c.title = 'One'
    end

    component :grid_two do |c|
      c.klass = Grid::Books
      c.title = 'Two'
    end

    def configure(c)
      super
      c.items = [:grid_one, :grid_two]
    end
  end
end
