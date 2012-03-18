module Netzke
  module Sequel
    module ComboboxOptions
      def netzke_combo_options_for(column, query = "")
        ds = query.empty? ? self : filter(column.to_sym.ilike("#{query}%"))
        ds.select(column.to_sym).distinct.all.map &column.to_sym
      end
    end
  end
end
