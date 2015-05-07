class FileRecord < ActiveRecord::Base
  validates :name, presence: true

  acts_as_nested_set

  # Picked up by the tree node
  def leaf
    !is_dir?
  end

  # To test snake_case column names
  def file_size
    size
  end

  # shown in the treecolumn
  def node_label
    name
  end

  # ... and more:
  # def expandable
  #   true
  # end

  # def qtip
  #   'Some qtip'
  # end

  # def checked
  #   true
  # end
end
