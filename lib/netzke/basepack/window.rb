module Netzke
  module Basepack
    # == Window
    # Ext.Window-based component able to nest other Netzke components
    #
    # == Features
    # * Persistent position and dimensions
    #
    # == Instance configuration
    # <tt>:item</tt> - nested Netzke component, e.g.:
    #
    #     netzke :window, :item => {:class_name => "GridPanel", :model => "User"}
    class Window < Netzke::Base
      js_configure do |c|
        c.extend = "Ext.window.Window"
        c.mixin
      end

      endpoint :set_size_and_position do |params|
        update_persistent_options(
          :x => params[:x].to_i,
          :y => params[:y].to_i,
          :width => params[:w].to_i,
          :height => params[:h].to_i
        )
        {}
      end
    end
  end
end
