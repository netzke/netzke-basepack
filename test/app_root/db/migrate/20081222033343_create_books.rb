class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title
      t.integer :amount
      t.integer :genre_id

      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
