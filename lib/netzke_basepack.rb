# NetzkeBasepack
require 'netzke/ar_ext'
require 'netzke/grid'
require 'netzke/container'
require 'netzke/accordion'
require 'netzke/properties_tool'

%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

ActiveRecord::Base.class_eval do
  include Netzke::ActiveRecordExtensions
end
