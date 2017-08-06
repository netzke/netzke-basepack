class Book < ActiveRecord::Base
  belongs_to :author
  validates :title, presence: true

  # prevent deleting books with title 'Untouchable'
  before_destroy :confirm_deletion

  def read_only_virtual_attr
    "Dummy value"
  end

  def assignable_virtual_attr=(value)
  end

  protected

  def confirm_deletion
    if title == "Untouchable"
      errors.add :base, "Can't delete #{title}"
      throw :abort
    end

    errors.blank?
  end
end
