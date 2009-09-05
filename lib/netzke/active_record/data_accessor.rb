module Netzke::ActiveRecord
  # Provides extensions to those ActiveRecord-based models that provide data to the "data accessor" widgets,
  # like GridPanel, FormPanel, etc
  module DataAccessor
    # Transforms a record to array of values according to the passed columns.
    def to_array(columns)
      res = []
      for c in columns
        nc = c.is_a?(Symbol) ? {:name => c} : c
        res << send(nc[:name]) unless nc[:excluded]
      end
      res
    end
  end
end

