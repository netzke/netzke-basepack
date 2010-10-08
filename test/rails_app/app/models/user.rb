class User < ActiveRecord::Base
  # scope :latest, lambda {|param| where(:created_at.gt => param)}
  belongs_to :role
  
  # netzke_attribute :first_name, :editor => {:xtype => "combobox"}
end
