class CreateNetzkeFormPanelFields < ActiveRecord::Migration
  def self.up
    create_table :netzke_form_panel_fields do |t|
      t.string    :name
      t.string    :label
      t.boolean   :read_only
      t.integer   :position
      t.boolean   :hidden
      t.integer   :width
      t.integer   :height
      t.string    :editor, :limit => 32

      t.integer   :layout_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :netzke_form_panel_fields
  end
end
