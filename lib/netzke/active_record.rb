require 'netzke/active_record/attributes'
require 'netzke/active_record/combobox_options'
require 'netzke/active_record/relation_extensions'

module Netzke
  module ActiveRecord
  end
end

if defined? ActiveRecord
  # Extend ActiveRecord
  ActiveRecord::Base.class_eval do
    include ::Netzke::ActiveRecord::Attributes
    include ::Netzke::ActiveRecord::ComboboxOptions
  end

  ActiveRecord::Relation.class_eval do
    include ::Netzke::ActiveRecord::RelationExtensions
  end
end
