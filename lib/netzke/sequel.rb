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

    # Emulate ARs timestamp behavior
    def before_create
      self.created_at ||= Time.now
      self.updated_at ||= Time.now
    end

    def before_update
      self.updated_at ||= Time.now
    end
  end
end

