require 'netzke/basepack/version'

if defined? ActiveRecord
  require 'netzke/active_record'
end
if defined? DataMapper
  require 'netzke/data_mapper'
end
if defined? Sequel
  require 'netzke/sequel'
end

require 'netzke/basepack/data_adapters/abstract_adapter'
require 'netzke/basepack/data_adapters/active_record_adapter' if defined? ActiveRecord
require 'netzke/basepack/data_adapters/data_mapper_adapter' if defined? DataMapper
require 'netzke/basepack/data_adapters/sequel_adapter' if defined? Sequel

module Netzke
  module Basepack
    mattr_accessor :with_icons

    mattr_accessor :icons_uri

    class << self

      # Called from netzke-basepack.rb
      def init
        Netzke::Core.ext_javascripts << "#{File.dirname(__FILE__)}/../../javascripts/xdatetime.js"
        Netzke::Core.ext_javascripts << "#{File.dirname(__FILE__)}/../../javascripts/basepack.js"

        Netzke::Core.ext_stylesheets << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"
      end

      # Use it to confirure Basepack in the initializers, e.g.:
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
