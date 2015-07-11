# External dependencies
require 'netzke-core'
require 'active_support/dependencies'

require 'netzke/basepack'

module Netzke
  module Basepack
    class Engine < ::Rails::Engine

      %w[en de ru es].each do |lang|
        I18n.load_path << File.dirname(__FILE__) + "/../locales/#{lang}.yml"
      end

      # Make components and modules auto-loadable
      config.autoload_paths << File.dirname(__FILE__)
    end
  end
end

Netzke::Basepack.init
