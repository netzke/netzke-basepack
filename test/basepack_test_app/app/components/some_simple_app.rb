class SomeSimpleApp < Netzke::Basepack::SimpleApp
  def menu
    [:load_simple_accordion, :load_user_grid, :load_simple_tab_panel] + super
  end

  action :load_simple_accordion do |a|
    a.icon = :application_tile_vertical
    a.handler = :netzke_load_component_by_action
    a.component = :some_accordion
    a.text = "Some accordion"
  end

  action :load_user_grid do |a|
    a.icon = :table
    a.handler = :netzke_load_component_by_action
    a.component = :user_grid
    a.text = "User grid"
  end

  action :load_simple_tab_panel do |a|
    a.icon = :table_multiple
    a.handler = :netzke_load_component_by_action
    a.component = :some_tab_panel
    a.text = "Some tab panel"
  end

  component :user_grid
  component :some_accordion
  component :some_tab_panel

  # Wrapping up original layout into a border-layout with the north panel being a fancy header
  def configure(c)
    super
    c.border = false
    c.items = [{
      :region => :north,
      :height => 35,
      :html => %Q{
        <div style="margin:10px; color:#333; text-align:center; font-family: Helvetica;">
          Simple <span style="color:#B32D15">Netzke</span> app
        </div>
      },
      # TODO: this has no effect anymore:
      # :bodyStyle => {:background => "#AAA url(\"/images/header-deco.gif\") top left repeat-x"}
    },{
      :region => :center,
      :layout => 'border',
      :items => config.items
    }]
  end
end
