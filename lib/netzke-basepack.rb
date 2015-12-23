# External dependencies
require 'netzke-core'
require 'active_support/dependencies'

require 'netzke/basepack'

module Netzke
  module Basepack
    class Engine < ::Rails::Engine

      # load Basepack locale files
      Dir[File.dirname(__FILE__) + "/../locales/*.yml"].each do |file|
        I18n.load_path << file
      end

      # Make components and modules auto-loadable
      config.autoload_paths << File.dirname(__FILE__)
    end
  end
end

Netzke::Basepack.init
