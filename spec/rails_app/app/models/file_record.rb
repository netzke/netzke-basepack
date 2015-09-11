class FileRecord < ActiveRecord::Base
  validates :file_name, presence: true

  acts_as_nested_set

  # shown in the treecolumn
  def node_label
    file_name
  end
end
