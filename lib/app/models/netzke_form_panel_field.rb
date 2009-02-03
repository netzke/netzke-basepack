class NetzkeFormPanelField < ActiveRecord::Base
  belongs_to :layout, :class_name => "NetzkeLayout"
  
  acts_as_list :scope => :layout

  expose_columns :id, 
    :name,
    :field_label,
    :hidden, 
    {:name => :width, :width => 50}, 
    {:name => :height, :width => 50}


  def self.create_layout_for_widget(widget)
    layout = NetzkeLayout.create(:widget_name => widget.id_name, :items_class => self.name, :user_id => NetzkeLayout.user_id)

    columns = widget.default_db_fields

    for c in columns
      config_for_create = c.merge(:layout_id => layout.id).stringify_values!
      create(config_for_create)
    end
    
    layout
  end
end
