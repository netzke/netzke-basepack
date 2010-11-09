# External dependencies
require 'netzke-core'
require 'active_support/dependencies'

# path = File.dirname(__FILE__)
# $LOAD_PATH << path

# Make components auto-loadable
ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

require 'netzke/basepack'

module Netzke
  autoload :Ext, 'ext'

  module Basepack
    class Engine < ::Rails::Engine
      config.after_initialize do
        I18n.load_path << File.dirname(__FILE__) + '/../locale/en.yml'
      end
    end
  end

end

Netzke::Basepack.init

# Netzke::Core.javascripts << "#{File.dirname(__FILE__)}/../../javascripts/basepack.js"
# Netzke::Core.stylesheets << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"

# Make this plugin auto-reloadable for easier development
# ActiveSupport::Dependencies.autoload_once_paths.delete(path)

# Make gem's models auto-loadable
# %w{ models }.each do |dir|
#   path = File.join(File.dirname(__FILE__), 'app', dir)
#   $LOAD_PATH << path
#   ActiveSupport::Dependencies.autoload_paths << path
#   ActiveSupport::Dependencies.autoload_once_paths.delete(path)
# end

# Include javascript & styles required by all basepack components.
# These files will get loaded at the initial load of the framework (along with Ext and Netzke-core).


# FIXME: The following stylesheet inclusion doesn't *really* belong here, being component-specific,
# but I don't see any other solution for now. The problem is that these stylesheets come straight from
# Ext JS, having *relative* URLs to the images, which doesn't allow us to include them all together as those stylesheets
# from Netzke.

# Used by FormPanel (file upload field)
# Netzke::Base.config[:external_css] << "/extjs/examples/ux/fileuploadfield/css/fileuploadfield"

# Used by GridPanel
# Netzke::Base.config[:external_css] << "/extjs/examples/ux/gridfilters/css/RangeMenu"
# Netzke::Base.config[:external_css] << "/extjs/examples/ux/gridfilters/css/GridFilters"

