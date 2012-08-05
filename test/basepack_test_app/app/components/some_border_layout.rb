class SomeBorderLayout < Netzke::Basepack::BorderLayoutPanel
  js_configure do |c|
    c.on_update_west_region = <<-JS
      function(){
        this.child('component[name="user_grid"]').body.update('Updated West Region Content');
      }
    JS

    c.on_update_center_region = <<-JS
      function(){
        this.child('component[name="role_grid"]').body.update('Updated Center Region Content');
      }
    JS
  end

  def configure(c)
    super
    c.items = [
      {:title => "Who", :class_name => "Netzke::Basepack::GridPanel", :region => :center, :model => "User", :name => :user_grid},
      {:title => "Item Two", :class_name => "Netzke::Basepack::GridPanel", :region => :west, :width => 500, :split => true, :collapsible => true, :model => "Role", :name => :role_grid}
    ]
    c.bbar = [:update_center_region, :update_west_region]
  end

  action :update_center_region
  action :update_west_region

end
