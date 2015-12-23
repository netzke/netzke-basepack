module Grid
  module Permissions
    class Read < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.permissions = {read: false}
      end
    end
  end
end
