module Grid
  module Permissions
    class Delete < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.permissions = {delete: false}
      end
    end
  end
end
