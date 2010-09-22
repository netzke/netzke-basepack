module Netzke
  module Component
    class GridPanel < Base
      class MultiEditForm < FormPanel
      
        # Replace checkbox for boolean fields with tristate checkbox
        def attr_type_to_xtype_map
          super.merge({
            :boolean => :tricheckbox
          })
        end
      
      end
    end
  end
end