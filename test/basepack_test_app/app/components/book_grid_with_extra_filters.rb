# This requires a patch to Ext examples/ux/grid
# NOTE: not used!
class BookGridWithExtraFilters < Netzke::Basepack::GridPanel
  model "Book"

  js_include Netzke::Core.ext_path.join("examples", "ux/grid/filter/EneFilter.js")
  js_include Netzke::Core.ext_path.join("examples", "ux/grid/menu/EneMenu.js")

  Netzke::Core.external_ext_css << "#{Netzke::Core.ext_uri}/examples/ux/grid/css/EneMenu"

  def configure!
    super
    @config[:columns] = [{:name => :title, :filter => {:type => :ene}}, :exemplars, :digitized, :notes]
  end
end
