require 'netzke/active_record/association_attributes'
require 'netzke/active_record/attributes'
require 'netzke/active_record/combobox_options'
require 'netzke/active_record/data_accessor'

# Extend ActiveRecord
ActiveRecord::Base.class_eval do
  include ::Netzke::ActiveRecord::AssociationAttributes
  include ::Netzke::ActiveRecord::Attributes
  include ::Netzke::ActiveRecord::ComboboxOptions
end
