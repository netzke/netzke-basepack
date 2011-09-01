class AddLastReadAtToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :last_read_at, :datetime
  end

  def self.down
    remove_column :books, :last_read_at
  end
end
