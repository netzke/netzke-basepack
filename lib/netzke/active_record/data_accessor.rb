module Netzke::ActiveRecord
  # Provides extensions to those ActiveRecord-based models that provide data to the "data accessor" widgets,
  # like GridPanel, FormPanel, etc
  module DataAccessor
    
    # Allow specify the netzke widget that requires this data. Virtual attributes may be using it to produce
    # widget-dependent result.
    def netzke_widget=(widget)
      @netzke_widget = widget
    end
    
    def netzke_widget
      @netzke_widget
    end
    
    # Transforms a record to array of values according to the passed columns.
    def to_array(columns, widget = nil)
      self.netzke_widget = widget
      res = []
      for c in columns
        nc = c.is_a?(Symbol) ? {:name => c} : c
        begin
          res << send(nc[:name]) unless nc[:excluded]
        rescue
          # So that we don't crash at a badly configured column
          res << "UNDEF"
        end
      end
      res
    end
  end
end

