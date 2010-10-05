module Netzke
  module Basepack
    class << self
      def initialize
        Netzke::Component::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../../javascripts/basepack.js"
        Netzke::Component::Base.config[:stylesheets] << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"
        
        # Detect icons
        Netzke::Component::Base.config[:icons_uri] ||= "/images/icons"
        if Netzke::Component::Base.config[:with_icons].nil? && defined?(Rails)
          Netzke::Component::Base.config[:with_icons] = File.exists?("#{Rails.root}/public#{Netzke::Component::Base.config[:icons_uri]}")
        end
      end
    end
  end
end