class CreateIllustrations < ActiveRecord::Migration[4.2]
  def change
    create_table :illustrations do |t|
      t.string :title
      t.string :image

      t.timestamps null: false
    end
  end
end
