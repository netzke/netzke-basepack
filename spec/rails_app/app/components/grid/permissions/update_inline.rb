module Grid
  module Permissions
    class UpdateInline < Netzke::Grid::Base
      def configure(c)
        super
        c.model = Book
        c.permissions = { update: false }
        c.editing = :inline
      end
    end
  end
end
