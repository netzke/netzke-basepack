class User < ActiveRecord::Base
  scope :latest, where(:created_at.gt => 1.day.ago)
  belongs_to :role
  
  # netzke_attribute :first_name, :editor => {:xtype => "combobox"}
end
