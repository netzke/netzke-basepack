class Issue < ActiveRecord::Base
  attr_accessible :developer_id, :project_id, :status_id, :title
  belongs_to :developer
  belongs_to :project
  belongs_to :status
end
