# NetzkeBasepack
require 'netzke/ar_ext'
# require 'netzke/properties_tool'
# require 'netzke/container'
# require 'netzke/accordion'
# require 'netzke/grid'

%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/basepack.js"