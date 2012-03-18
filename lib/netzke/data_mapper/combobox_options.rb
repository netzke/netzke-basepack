module Netzke
  module DataMapper
    module ComboboxOptions
      def netzke_combo_options_for(column, query = "")
        # NOTE: :order=>[column.to_sym.asc] is necessary as per http://datamapper.org/docs/find.html, Version 1.2.0
        values=all(:fields=>[column], :unique=>true, :order=>[column.to_sym.asc])
        (query.blank? ? values : values.all(column.to_sym.like => "#{query}%")).map &column.to_sym
      end
    end
  end
end
