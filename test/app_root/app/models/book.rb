class Book < ActiveRecord::Base
  belongs_to :genre
  
  # netzke_virtual_attribute :recent => {:read_only => true}
  
  def recent
    updated_at > 1.hour.ago ? "Yes" : "No"
  end
end
