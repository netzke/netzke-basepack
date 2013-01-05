class CreateDevelopers < ActiveRecord::Migration
  def change
    create_table :developers do |t|

      t.timestamps
    end
  end
end
