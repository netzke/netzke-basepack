class CreateTables < ActiveRecord::Migration[4.2]
  def change
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name
      t.integer :year
      t.integer :prize_count

      t.timestamps null: false
    end

    create_table :books do |t|
      t.string :title
      t.integer :author_id
      t.integer :exemplars
      t.boolean :digitized, :default => false
      t.text :notes
      t.date :published_on
      t.datetime :last_read_at
      t.string :tags
      t.integer :rating
      t.decimal :price, precision: 7, scale: 2

      t.timestamps null: false
    end

    create_table :book_with_custom_primary_keys, primary_key: :uid, id: false do |t|
      t.integer :uid
      t.string :title
      t.integer :author_id

      t.timestamps null: false
    end
  end
end
