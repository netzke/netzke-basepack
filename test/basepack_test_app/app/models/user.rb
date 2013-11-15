class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :role, :role_id
  # scope :latest, lambda {|param| where(:created_at.gt => param)}
  belongs_to :role
  has_one :address
end
