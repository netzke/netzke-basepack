class Author < ActiveRecord::Base
  has_many :books

  scope :sorted_by_name, lambda { |dir| order("last_name #{dir}, first_name #{dir}") }

  # virtual attribute
  def name
    "#{last_name}, #{first_name}"
  end
end
