class CreateContinents < ActiveRecord::Migration
  def self.up
    create_table :continents do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :continents
  end
end
