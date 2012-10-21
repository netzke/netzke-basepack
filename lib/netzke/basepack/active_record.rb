require 'netzke/basepack/active_record/relation_extensions'

module Netzke
  module Basepack
    module ActiveRecord
    end
  end
end

::ActiveRecord::Relation.class_eval do
  include ::Netzke::Basepack::ActiveRecord::RelationExtensions
end
