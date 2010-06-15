module Netzke::ActiveRecord
  
  # Extend ActiveRecord
  ActiveRecord::Base.class_eval do
    include ::Netzke::ActiveRecord::AssociationAttributes
    include ::Netzke::ActiveRecord::Attributes
    include ::Netzke::ActiveRecord::ComboboxOptions
  end
  
end