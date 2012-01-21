module Netzke
  module DataMapper
    module ComboboxOptions
        def netzke_combo_options_for(column, query = "")

          values=all(:fields=>[column], :unique=>true, :order=>nil)
          (query.blank? ? values : values.all(column.to_sym.like => "#{query}%")).map &column.to_sym
        end
    end
  end
end
