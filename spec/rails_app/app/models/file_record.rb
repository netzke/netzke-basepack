class FileRecord < ActiveRecord::Base
  validates :name, presence: true

  acts_as_nested_set

  # To test snake_case column names
  def file_size
    size
  end

  # shown in the treecolumn
  def node_label
    name
  end

  def build_tree_data
    attributes.tap do |attrs|
      if children.count > 0
        attrs[:children] = children.map do |child|
          child.build_tree_data
        end
      end
    end
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
