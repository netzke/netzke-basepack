# External dependencies
require 'netzke-core'
require 'active_support/dependencies'

# Make components auto-loadable
ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

require 'netzke/basepack'

module Netzke
  module Basepack
    class Engine < Rails::Engine

      %w[en de ru es].each do |lang|
        I18n.load_path << File.dirname(__FILE__) + "/../locales/#{lang}.yml"
      end

      config.after_initialize do
        Netzke::Core.external_ext_css << "#{Netzke::Core.ext_uri}/examples/ux/grid/css/RangeMenu"
        Netzke::Core.external_ext_css << "#{Netzke::Core.ext_uri}/examples/ux/grid/css/GridFilters"
        Netzke::Core.external_ext_css << "#{Netzke::Core.ext_uri}/examples/ux/css/CheckHeader"
      end
    end
  end
end

Netzke::Basepack.init
