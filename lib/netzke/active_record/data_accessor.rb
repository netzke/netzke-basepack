module Netzke::ActiveRecord
  # Provides extensions to those ActiveRecord-based models that provide data to the "data accessor" widgets,
  # like GridPanel, FormPanel, etc
  module DataAccessor
    # Transforms a record to array of values according to the passed columns.
    def to_array(columns, widget = nil)
      # self.netzke_widget = widget
      res = []
      for c in columns
        begin
          res << send(c[:name]) unless c[:included] == false
        rescue
          # So that we don't crash at a badly configured column
          res << "UNDEF"
        end
      end
      res
    end
  end
end

