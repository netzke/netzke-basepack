require 'netzke/basepack/version'

require 'netzke/basepack/data_adapters/abstract_adapter'

if defined? ActiveRecord
  require 'netzke/basepack/active_record'
  require 'netzke/basepack/data_adapters/active_record_adapter'
end

require 'netzke/basepack/item_persistence'

module Netzke
  module Basepack
    mattr_accessor :with_icons

    mattr_accessor :icons_uri

    class << self
      # Called from netzke-basepack.rb
      def init
        %w[netzkeremotecombo xdatetime basepack columns].each do |name|
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
