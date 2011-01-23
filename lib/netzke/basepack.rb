require 'netzke/basepack/version'
require 'netzke/active_record'

module Netzke
  module Basepack
    mattr_accessor :with_icons

    mattr_accessor :icons_uri

    class << self
      # Called from netzke-basepack.rb
      def init
        Netzke::Core.ext_javascripts << "#{File.dirname(__FILE__)}/../../javascripts/basepack.js"
        Netzke::Core.ext_stylesheets << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"

        Netzke::Core.external_ext_css << "/extjs/examples/ux/gridfilters/css/RangeMenu"
        Netzke::Core.external_ext_css << "/extjs/examples/ux/gridfilters/css/GridFilters"
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
