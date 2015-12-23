module Grid
  module Permissions
    class Update < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.permissions = {update: false}
      end
    end
  end
end
