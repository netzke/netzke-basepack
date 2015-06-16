module Grid
  class ProhibitRead < Netzke::Basepack::Grid
    def configure(c)
      super
      c.model = 'Book'
      c.prohibit_read = true
    end
  end
end
