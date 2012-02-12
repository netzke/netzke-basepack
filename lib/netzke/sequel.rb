require 'netzke/sequel/attributes'
require 'netzke/sequel/combobox_options'
#require 'netzke/sequel/relation_extensions'

module Netzke
  module Sequel
  end
end

if defined? Sequel
  # Extend Sequel
  Sequel::Model.class_eval do
    include ::Netzke::Sequel::Attributes
    include ::Netzke::Sequel::ComboboxOptions
    include ::Netzke::Sequel::RelationExtensions
  end
end

