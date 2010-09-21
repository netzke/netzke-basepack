class User < ActiveRecord::Base
  scope :latest, where(:id.gt => 7)
  belongs_to :role
end
