class CreateFileRecords < ActiveRecord::Migration
  def change
    create_table :file_records do |t|
      t.boolean :is_dir, default: false
      t.string :name, null: false
      t.integer :size, default: 0
      t.references :parent, index: true, null: true
      t.integer :lft, index: true, null: false
      t.integer :rgt, index: true, null: false

      t.timestamps null: true
    end
    add_foreign_key :file_records, :parents
    add_foreign_key :file_records, :lfts
    add_foreign_key :file_records, :rgts
  end
end
