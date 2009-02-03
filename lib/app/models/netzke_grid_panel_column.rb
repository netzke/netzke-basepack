class NetzkeGridPanelColumn < ActiveRecord::Base
  belongs_to :layout, :class_name => "NetzkeLayout"
  
  acts_as_list :scope => :layout

  expose_columns :id, 
    :name,
    :label,
    {:name => :read_only, :label => "R/O"}, 
    :hidden, 
    {:name => :width, :width => 50}, 
    {:name => :editor, :editor => :combo_box},
    {:name => :renderer, :editor => :combo_box}
  


  def self.create_layout_for_widget(widget)
    layout = NetzkeLayout.create_with_user(:widget_name => widget.id_name, :items_class => self.name)
    columns = widget.default_db_fields

    for c in columns
      config_for_create = c.merge(:layout_id => layout.id).stringify_values!
      create(config_for_create)
    end
    
    layout
  end
end
