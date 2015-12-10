module Netzke
  module Basepack
    # This plugin allows you to add form fields to any docked item (toolbar) of the grid, bind them to model
    # attribute, and assign the search operator. The grid will be updated on changing those fields, to reflect the
    # query.
    #
    # See `Grid::LiveSearch` in spec/rails_app for a usage example.
    #
    # == Configuration:
    #
    # [delay] - the delay between changing the value of the search fields, and the moment when the query is being issued
    # to the server; defaults to 500 (ms).
    #
    # == Configuring query fields
    #
    # Each field accepts the following parameters:
    #
    # [attr] - name of the attribute to be searched on; to search on associations, use the double-underscore notation
    # [op] - operation to apply for this attribute. Possible values are: contains, eq, gt, lt, gteq, lteq
    #
    # == Known issues
    #
    # Trying to search on a *virtual* column that is *not shown* in the grid will break. A fix would require refactoring
    # of +Grid::Columns+.
    class GridLiveSearch < Netzke::Plugin
    end
  end
end
