require 'netzke/basepack/version'
require 'netzke/active_record'

module Netzke
  module Basepack
    mattr_accessor :with_icons

    mattr_accessor :icons_uri

    class << self

      # Called from netzke-basepack.rb
      def init
        # Netzke::Core.ext_javascripts << "#{File.dirname(__FILE__)}/../../javascripts/datetimefield.js"
        Netzke::Core.ext_javascripts << "#{File.dirname(__FILE__)}/../../javascripts/basepack.js"

        Netzke::Core.ext_stylesheets << "#{File.dirname(__FILE__)}/../../stylesheets/datetimefield.css"
        Netzke::Core.ext_stylesheets << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"

        # TODO: make ext paths configurable
        # Netzke::Core.external_ext_css << "/extjs4/examples/ux/gridfilters/css/RangeMenu"
        # Netzke::Core.external_ext_css << "/extjs4/examples/ux/gridfilters/css/GridFilters"
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
