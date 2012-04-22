class SomeSimpleApp < Netzke::Basepack::SimpleApp
  def menu
    [:load_simple_accordion, :load_user_grid, :load_simple_tab_panel] + super
  end

  action :load_simple_accordion do |a|
    a.icon = :application_tile_vertical
    a.handler = :load_netzke_component_by_action
    a.component = :simple_accordion
    a.text = "Simple accordion"
  end

  action :load_user_grid do |a|
    a.icon = :table
    a.handler = :load_netzke_component_by_action
    a.component = :user_grid
    a.text = "User grid"
  end

  action :load_simple_tab_panel do |a|
    a.icon = :table_multiple
    a.handler = :load_netzke_component_by_action
    a.component = :simple_tab_panel
    a.text = "Simple tab panel"
  end

  component :user_grid
  component :simple_accordion
  component :simple_tab_panel

  js_property :border, false

  # Wrapping up original layout into a border-layout with the north panel being a fancy header
  def configure
    super
    config.merge!(:items => [{
      :region => :north,
      :height => 35,
      :html => %Q{
        <div style="margin:10px; color:#333; text-align:center; font-family: Helvetica;">
          Simple <span style="color:#B32D15">Netzke</span> app
        </div>
      }
      # TODO: this has no effect anymore:
      # :bodyStyle => {:background => "#AAA url(\"/images/header-deco.gif\") top left repeat-x"}
    },{
      :region => :center,
      :layout => 'border',
      :items => config.items
    }])
  end
end
