module Netzke
  # TODO: rename this class, or better even, make a module out of it
  class Column
    def self.default_dbfields_for_widget(widget, mode = :grid)
      raise ArgumentError, "No data_class_name specified for widget #{widget.config[:name]}" if widget.config[:data_class_name].nil?

      # layout = NetzkeLayout.create(:widget_name => widget.id_name, :items_class => self.name, :user_id => NetzkeLayout.user_id)

      data_class = widget.config[:data_class_name].constantize

      exposed_columns = normalize_columns(data_class.exposed_columns) # columns exposed from the data class

      columns_from_config = widget.config[:columns] && normalize_columns(widget.config[:columns]) # columns specified in widget's config

      if columns_from_config
        # reverse-merge each column hash from config with each column hash from exposed_columns (columns from config have higher priority)
        for c in columns_from_config
          corresponding_exposed_column = exposed_columns.find{ |k| k[:name] == c[:name] }
          c.reverse_merge!(corresponding_exposed_column) if corresponding_exposed_column
        end
        columns_for_create = columns_from_config
      else
        # we didn't have columns configured in widget's config, so, use the columns from the data class
        columns_for_create = exposed_columns
      end

      res = []
      for c in columns_for_create
        # finally reverse-merge them with the defaults from the data_class
        res << (mode == :grid ? data_class.default_column_config(c) : data_class.default_field_config(c))
      end
      
      res
    end

    def self.default_columns_for_widget(widget)
      default_dbfields_for_widget(widget, :grid)
    end
    
    def self.default_fields_for_widget(widget)
      default_dbfields_for_widget(widget, :form)
    end
    
    protected

    # like this: [:col1, {:name => :col2}, :col3] => [{:name => :col1}, {:name => :col2}, {:name => :col3}]
    def self.normalize_columns(items)
      items.map{|c| c.is_a?(Symbol) ? {:name => c} : c}
    end
    
  end
end