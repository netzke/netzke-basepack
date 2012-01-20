module Netzke
  module DataMapper
    module ComboboxOptions
        def netzke_combo_options_for(column, query = "")
          sql = if query.empty?
                  "select distinct #{column} from #{storage_name}"
                else
                  "select distinct #{column} from #{storage_name} where #{column} like '#{query}%'"
                end

          repository(:default).adapter.select(sql)
        end
    end
  end
end
