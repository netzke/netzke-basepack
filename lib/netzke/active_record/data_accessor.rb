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
          next if c[:included] == false
          v = send(c[:name])
          # a work-around for to_json not taking the current timezone into account when serializing ActiveSupport::TimeWithZone
          v = v.to_datetime.to_s(:db) if v.is_a?(ActiveSupport::TimeWithZone)
          res << v 
        rescue NoMethodError
          # So that we don't crash at a badly configured column
          res << "UNDEF"
        end
      end
      res
    end
  end
end

