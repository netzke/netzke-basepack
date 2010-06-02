class CreateNetzkeFieldLists < ActiveRecord::Migration
  def self.up
    create_table :netzke_field_lists do |t|
      t.string :name
      t.text :value
      t.string :type
      t.string :model_name
      t.integer :user_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :netzke_field_lists
  end
end
