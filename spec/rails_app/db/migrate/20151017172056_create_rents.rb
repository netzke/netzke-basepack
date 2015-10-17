class CreateRents < ActiveRecord::Migration
  def change
    create_table :rents do |t|
      t.references :user, index: true
      t.references :book, index: true

      t.timestamps null: false
    end
    add_foreign_key :rents, :users
    add_foreign_key :rents, :books
  end
end
