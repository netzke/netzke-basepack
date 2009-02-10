class CreateNetzkeFormPanelFields < ActiveRecord::Migration
  def self.up
    create_table :netzke_form_panel_fields do |t|
      t.string    :name
      t.string    :field_label
      t.boolean   :hidden
      t.boolean   :disabled
      t.string    :xtype
      t.string    :ext_config, :limit => 1024

      t.integer   :position
      t.integer   :layout_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :netzke_form_panel_fields
  end
end
