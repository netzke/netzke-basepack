require 'netzke/active_record'

module Netzke
  module Basepack
    class << self
      def initialize
        Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../../javascripts/basepack.js"
        Netzke::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"
        
        # Detect icons
        Netzke::Base.config[:icons_uri] ||= "/images/icons"
        if Netzke::Base.config[:with_icons].nil? && defined?(Rails)
          Netzke::Base.config[:with_icons] = File.exists?("#{Rails.root}/public#{Netzke::Base.config[:icons_uri]}")
        end
      end
    end
  end
end