class Author < ActiveRecord::Base
  has_many :books

  scope :sorted_by_name, lambda { |dir| order("first_name #{dir}, last_name #{dir}") }

  # virtual attribute
  def name
    "#{first_name} #{last_name}"
  end
end
