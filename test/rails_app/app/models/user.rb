class User < ActiveRecord::Base
  # scope :latest, lambda {|param| where(:created_at.gt => param)}
  belongs_to :role
  has_one :address
end
