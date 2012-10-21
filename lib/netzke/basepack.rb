require 'netzke/basepack/version'

if defined? ActiveRecord
  require 'netzke/basepack/active_record'
  require 'netzke/basepack/data_adapters/active_record_adapter'
end
# if defined? DataMapper
#   require 'netzke/data_mapper'
# require 'netzke/basepack/data_adapters/data_mapper_adapter'
# end
# if defined? sequel
#   require 'netzke/sequel'
# require 'netzke/basepack/data_adapters/sequel_adapter'
# end

require 'netzke/basepack/data_adapters/abstract_adapter'
require 'netzke/basepack/items_persistence'

module Netzke
  module Basepack
    mattr_accessor :with_icons

    mattr_accessor :icons_uri

    class << self

      # Called from netzke-basepack.rb
      def init
        %w[netzkeremotecombo xdatetime basepack].each do |name|
          Netzke::Core.ext_javascripts << "#{File.dirname(__FILE__)}/../../javascripts/#{name}.js"
        end

        Netzke::Core.ext_stylesheets << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"
      end

      # Use this to confirure Basepack in the initializers, e.g.:
      #
      #     Netzke::Basepack.setup do |config|
      #       config.icons_uri = "/images/famfamfam/icons"
      #     end
      def setup
        yield self
      end
    end

  end
end
