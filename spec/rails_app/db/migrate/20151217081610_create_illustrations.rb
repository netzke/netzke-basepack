class CreateIllustrations < ActiveRecord::Migration
  def change
    create_table :illustrations do |t|
      t.string :title
      t.string :image

      t.timestamps null: false
    end
  end
end
