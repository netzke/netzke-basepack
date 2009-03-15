require 'netzke/ar_ext'

class NetzkeGridPanelColumn < ActiveRecord::Base
  belongs_to :layout, :class_name => "NetzkeLayout"
  
  acts_as_list :scope => :layout

  validate :valid_ext_config

  expose_columns :id, 
    :name,
    :label,
    {:name => :read_only, :label => "R/O"}, 
    :hidden, 
    {:name => :width, :width => 50}, 
    {:name => :editor, :editor => :combo_box},
    {:name => :renderer, :editor => :combo_box},
    :ext_config
  
  def self.create_layout_for_widget(widget)
    layout = NetzkeLayout.create_with_user(:widget_name => widget.id_name, :items_class => self.name)
    columns = widget.default_db_fields

    for c in columns
      config_for_create = c.merge(:layout_id => layout.id).stringify_values!
      new_field = self.new
      ext_config = {}
      for k in config_for_create.keys
        if new_field.respond_to?("#{k}=")
          new_field.send("#{k}=", config_for_create[k]) 
        else
          ext_config[k] = config_for_create[k]
        end
      end

      new_field.ext_config = ext_config.to_js
      new_field.save!
      
      # config_for_create = c.merge(:layout_id => layout.id).stringify_values!
      # create(config_for_create)
    end
    
    layout
  end
  
  private
  
  def valid_ext_config
    begin
      JSON.parse(ext_config)
    rescue
      errors.add(:ext_config, "is not valid JSON")
    end
  end
  
end
