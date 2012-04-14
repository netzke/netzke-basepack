class SomeBorderLayout < Netzke::Basepack::BorderLayoutPanel
  items [
    {:title => "Who", :class_name => "Netzke::Basepack::GridPanel", :region => :center, :model => "User", :name => :user_grid},
    {:title => "Item Two", :class_name => "Netzke::Basepack::GridPanel", :region => :west, :width => 500, :split => true, :collapsible => true, :model => "Role", :name => :role_grid}
  ]

  js_property :bbar, [:update_center_region, :update_west_region]

  action :update_center_region
  action :update_west_region

  js_method :on_update_west_region, <<-JS
    function(){
      this.child('component[name="user_grid"]').body.update('Updated West Region Content');
    }
  JS

  js_method :on_update_center_region, <<-JS
    function(){
      this.child('component[name="role_grid"]').body.update('Updated Center Region Content');
    }
  JS
end
