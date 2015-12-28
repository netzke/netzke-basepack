module Grid
  module Permissions
    class Create < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.permissions = {create: false}
      end
    end
  end
end
