class CreateNetzkeGridPanelColumns < ActiveRecord::Migration
  def self.up
    create_table :netzke_grid_panel_columns do |t|
      t.string    :name
      t.string    :label
      t.boolean   :read_only
      t.boolean   :hidden
      t.integer   :width
      t.string    :editor, :limit => 32
      t.string    :renderer, :limit => 32
      t.string    :xtype, :limit => 32
      t.string    :ext_config, :limit => 1024

      t.integer   :position
      t.integer   :layout_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :netzke_grid_panel_columns
  end
end
