class AddPublishedOnToBooks < ActiveRecord::Migration
  def change
    add_column :books, :published_on, :date
  end
end
