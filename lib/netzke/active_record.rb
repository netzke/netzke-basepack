module Netzke::ActiveRecord
  
  # Extend ActiveRecord
  ActiveRecord::Base.class_eval do
    include AssociationAttributes
    include Attributes
    include ComboboxOptions
  end
  
end