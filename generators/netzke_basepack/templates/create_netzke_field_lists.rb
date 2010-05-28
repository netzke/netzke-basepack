class CreateNetzkeFieldLists < ActiveRecord::Migration
  def self.up
    create_table :netzke_field_lists do |t|
      t.string :name
      t.text :value
      t.integer :user_id
      t.integer :role_id
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :netzke_field_lists
  end
end
