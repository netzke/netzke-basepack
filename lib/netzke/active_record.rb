require 'netzke/active_record/relation_extensions'

module Netzke
  module ActiveRecord
  end
end

if defined? ActiveRecord
  ActiveRecord::Relation.class_eval do
    include ::Netzke::ActiveRecord::RelationExtensions
  end
end
