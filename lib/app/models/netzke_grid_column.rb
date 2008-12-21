class NetzkeGridColumn < ActiveRecord::Base
  belongs_to :layout, :class_name => "NetzkeLayout"
  
  acts_as_list :scope => :layout

  def self.create_with_defaults(column_config, klass)
    create(klass.default_column_config(column_config).stringify_values!)
  end
  
  def self.create_layout_for_widget(widget)
    raise ArgumentError, "No data_class_name specified for Grid widget" if widget.config[:data_class_name].nil?

    layout = NetzkeLayout.create(:widget_name => widget.id_name, :items_class => self.name, :user_id => NetzkeLayout.user_id)
    data_class = widget.config[:data_class_name].constantize
    exposed_columns = normalize_items(data_class.exposed_columns) # columns exposed from the data class
    columns_from_config = widget.config[:columns] && normalize_items(widget.config[:columns]) # columns specified in widget's config
    
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
    
    for c in columns_for_create
      config_for_create = data_class.default_column_config(c).merge(:layout_id => layout.id).stringify_values!
      create(config_for_create) # finally reverse-merge them with the defaults and create the column in the database
    end
    
    layout
  end
  
  protected
  
  # like this: [:col1, {:name => :col2}, :col3] => [{:name => :col1}, {:name => :col2}, {:name => :col3}]
  def self.normalize_items(items)
    items.map{|c| c.is_a?(Symbol) ? {:name => c} : c}
  end
  
  
end
