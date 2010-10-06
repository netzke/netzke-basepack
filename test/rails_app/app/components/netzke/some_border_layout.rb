module Netzke
  class SomeBorderLayout < Basepack::BorderLayoutPanel
    def config
      {
        :items => [
          {:title => "Who", :class_name => "Basepack::GridPanel", :region => :center, :model => "User", :name => :user_grid},
          {:title => "Item Two", :class_name => "Basepack::GridPanel", :region => :west, :width => 500, :split => true, :model => "Role", :name => :role_grid}
        ],
        :bbar => [:update_center_region.ext_action, :update_west_region.ext_action]
      }.deep_merge(super)
    end
    
    js_method :on_update_west_region, <<-JS
      function(){
        this.getChildComponent('user_grid').body.update('Updated West Region Content');
      }
    JS
    
    js_method :on_update_center_region, <<-JS
      function(){
        this.getChildComponent('role_grid').body.update('Updated Center Region Content');
      }
    JS
    
  end
end