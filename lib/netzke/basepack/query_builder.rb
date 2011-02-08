module Netzke
  module Basepack
    class QueryBuilder < Netzke::Base
      js_base_class "Ext.TabPanel"
      js_property :active_tab, 0

      js_mixin :query_builder

      component :search_panel do
        {
          :class_name => "Netzke::Basepack::SearchPanel",
          :model => config[:model],
          :query => config[:query],
          :auto_scroll => config[:auto_scroll]
        }
      end
    end
  end
end