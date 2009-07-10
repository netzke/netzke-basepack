module Netzke
  module DbFields
    #
    # Default fields for a widget of class GridPanel or FormPanel
    # It is a synthesis of 1) columns declared in the model, 2) columns provided in the configuration for the widget
    #
    def default_db_fields
      config[:data_class_name].nil? && raise(ArgumentError, "No data_class_name specified for widget #{config[:name]}")
      
      data_class          = config[:data_class_name].constantize
      exposed_attributes     = normalize_columns(data_class.netzke_exposed_attributes) # columns exposed from the data class
      columns_from_config = (config[:fields] || config[:columns]) && normalize_columns(config[:fields] || config[:columns]) # columns specified in widget's config

      if columns_from_config
        # reverse-merge each column hash from config with each column hash from exposed_attributes (columns from config have higher priority)
        for c in columns_from_config
          corresponding_exposed_column = exposed_attributes.find{ |k| k[:name] == c[:name] }
          c.reverse_merge!(corresponding_exposed_column) if corresponding_exposed_column
        end
        columns_for_create = columns_from_config
      else
        # we didn't have columns configured in widget's config, so, use the columns from the data class
        columns_for_create = exposed_attributes
      end

      res = []
      for c in columns_for_create
        # finally reverse-merge them with the defaults from the data_class
        res << (self.class.widget_type == :grid ? data_class.default_column_config(c) : data_class.default_field_config(c))
      end
      
      res
    end

    protected

    # [:col1, {:name => :col2}, :col3] 
    #    => [{:name => :col1}, {:name => :col2}, {:name => :col3}]
    def normalize_columns(items)
      items.map{|c| c.is_a?(Symbol) ? {:name => c} : c}
    end
    
  end
end