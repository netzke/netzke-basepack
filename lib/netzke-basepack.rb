# External dependencies
require 'netzke-core'
require 'searchlogic'

require 'netzke/ar_ext'

%w{ models }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

# Include the javascript
Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/basepack.js"

# TODO: implement configurable loading of JS, to spare the traffic at the initial loading
extjs_dir = "#{File.dirname(RAILS_ROOT)}/netzke_tutorial/public/extjs"
Netzke::Base.config[:javascripts] << "#{extjs_dir}/examples/grid-filtering/menu/EditableItem.js"
Netzke::Base.config[:javascripts] << "#{extjs_dir}/examples/grid-filtering/menu/RangeMenu.js"
Netzke::Base.config[:javascripts] << "#{extjs_dir}/examples/grid-filtering/grid/GridFilters.js"
%w{Boolean Date List Numeric String}.unshift("").each do |f|
  Netzke::Base.config[:javascripts] << "#{extjs_dir}/examples/grid-filtering/grid/filter/#{f}Filter.js"
end
Netzke::Base.config[:javascripts] << "#{File.dirname(__FILE__)}/../javascripts/filters.js"

# Make this plugin reloadable for easier development
ActiveSupport::Dependencies.load_once_paths.delete(File.join(File.dirname(__FILE__)))
