class SomeDynamicTabPanel < Netzke::Basepack::DynamicTabPanel
  js_configure do |c|
    c.mixin
  end

  action :load_in_current_tab
  action :load_in_new_tab

  component :child do |c|
    super(c)
    c.title = "Component #{c.client_config[:counter]}"
  end

  def configure(c)
    super
    c.bbar = [:load_in_current_tab, :load_in_new_tab]
  end
end
