class User < ActiveRecord::Base
  # scope :latest, lambda {|param| where(:created_at.gt => param)}
  belongs_to :role
  has_one :address

  before_destroy :is_admin
  def is_admin
    errors.add :base, "Can't delete Admin User." if self.first_name == "Admin"
    errors.blank?
  end
end
