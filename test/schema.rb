ActiveRecord::Schema.define(:version => 0) do
  create_table :books, :force => true do |t|
    t.string :name
    t.integer :amount
    t.integer :genre_id
  end
  create_table :genres, :force => true do |t|
    t.string :name
  end
end
