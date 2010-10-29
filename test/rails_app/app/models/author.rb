class Author < ActiveRecord::Base

  # virtual attribute
  def name
    "#{last_name}, #{first_name}"
  end
end
