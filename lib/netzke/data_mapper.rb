require 'netzke/data_mapper/attributes'
require 'netzke/data_mapper/combobox_options'
require 'netzke/data_mapper/relation_extensions'

module Netzke
  module DataMapper
  end
end

if defined? DataMapper
  # Extend DataMapper

  DataMapper::Model.append_extensions(Netzke::DataMapper::Attributes::ClassMethods)
  DataMapper::Model.append_inclusions(Netzke::DataMapper::Attributes)
  DataMapper::Model.append_extensions(Netzke::DataMapper::ComboboxOptions)
  DataMapper::Model.append_extensions(Netzke::DataMapper::RelationExtensions)
end

