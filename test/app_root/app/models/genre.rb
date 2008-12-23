class Genre < ActiveRecord::Base
  belongs_to :category
end
