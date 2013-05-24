class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.integer :author_id
      t.string :title
      t.integer :exemplars
      t.boolean :digitized, :default => false
      t.text :notes
      t.string :tags
      t.integer :rating
      t.decimal :price, precision: 7, scale: 2
      t.float :special_index

      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
