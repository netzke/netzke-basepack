class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :title
      t.integer :developer_id
      t.integer :project_id
      t.integer :status_id

      t.timestamps
    end
  end
end
