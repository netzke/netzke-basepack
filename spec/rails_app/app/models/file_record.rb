class FileRecord < ActiveRecord::Base
  acts_as_nested_set

  # Picked up by the tree node
  def leaf
    !is_dir?
  end

  # To test snake_case column names
  def file_size
    size
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
