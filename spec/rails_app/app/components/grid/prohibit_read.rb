module Grid
  class ProhibitRead < Netzke::Grid::Base
    def configure(c)
      super
      c.model = 'Book'
      c.prohibit_read = true
    end
  end
end
