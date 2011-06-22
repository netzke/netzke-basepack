# External dependencies
require 'netzke-core'
require 'active_support/dependencies'

# Make components auto-loadable
ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

require 'netzke/basepack'

module Netzke
  module Basepack
    class Engine < Rails::Engine

      I18n.load_path << File.dirname(__FILE__) + '/../locales/en.yml'
      I18n.load_path << File.dirname(__FILE__) + '/../locales/de.yml'
      
    end
  end
end

Netzke::Basepack.init
