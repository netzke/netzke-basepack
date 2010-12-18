module Netzke
  module Basepack
    # Basis for a Ext.Viewport-based one-page application
    #
    # Features:
    # * dynamic loading of components
    # * browser history support (press the "Back"-button to go to the previously loaded component)
    # * AJAX activity indicator
    class SimpleApp < Base

      js_base_class "Ext.Viewport"

      js_property :layout, :border

      js_include Netzke::Core.ext_location.join("examples", "ux/statusbar/StatusBar.js"), :statusbar_ext

      js_mixin :main

      def configuration
        super.merge(
          :items => [{
            :id => 'main-panel',
            :region => 'center',
            :layout => 'fit'
          },{
            :id => 'main-toolbar',
            :xtype => 'toolbar',
            :region => 'north',
            :height => 28,
            :items => menu
          },{
            :id => 'main-statusbar',
            :xtype => 'statusbar',
            :region => 'south',
            :height => 22,
            :statusAlign => 'right',
            :busyText => 'Busy...',
            :default_text => "Ready",
            :default_icon_cls => ""
          }]
        )
      end

      # Set the Logout button if Netzke::Base.user is set
      def menu
        []
      end

      # Html required for Ext.History to work
      def js_component_html
        super << %Q{
  <form id="history-form" class="x-hidden">
      <input type="hidden" id="x-history-field" />
      <iframe id="x-history-frame"></iframe>
  </form>
        }
      end
    end
  end
end
