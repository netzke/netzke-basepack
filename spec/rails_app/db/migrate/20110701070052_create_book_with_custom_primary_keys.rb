class CreateBookWithCustomPrimaryKeys < ActiveRecord::Migration
  def self.up
    create_table :book_with_custom_primary_keys, :primary_key => :uid do |t|
      t.integer :uid
      t.string :title
      t.integer :author_id

      t.timestamps
    end
  end

  def self.down
    drop_table :book_with_custom_primary_keys
  end
end
