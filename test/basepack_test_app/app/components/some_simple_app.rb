class SomeSimpleApp < Netzke::Basepack::SimpleApp
  def menu
    [:simple_accordion, :user_grid, :simple_tab_panel] + super
  end

  action :simple_accordion, :icon => :application_tile_vertical, :handler => :load_netzke_component_by_action
  action :user_grid, :icon => :table, :handler => :load_netzke_component_by_action
  action :simple_tab_panel, :icon => :table_multiple, :handler => :load_netzke_component_by_action

  component :user_grid
  component :simple_accordion
  component :simple_tab_panel, :active_tab => 0

  js_property :border, false

  # Wrapping up original layout into a border-layout with the north panel being a fancy header
  def configuration
    orig = super
    orig.merge(:items => [{
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
      :items => orig[:items]
    }])
  end
end
