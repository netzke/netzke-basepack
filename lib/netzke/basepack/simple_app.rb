module Netzke
  module Basepack
    # Basis for a Ext.container.Viewport-based one-page application.
    #
    # == Features:
    # * dynamic loading of components
    # * browser history support (press the "Back"-button to go to the previously loaded component)
    # * AJAX activity indicator
    #
    # == Extending SimpleApp
    # You may want to extend SimpleApp to provide a custom layout. Make sure you create three regions with predefined itemId's that will be used by SimpleApp. You can use the following methods defined by SimpleApp: main_panel_config, status_bar_config, and menu_bar_config, e.g.:
    #
    #     class MySimpleApp < Netzke::Basepack::SimpleApp
    #
    #       def configuration
    #         super.merge(
    #           :items => [my_custom_navigation_config, main_panel_config, menu_bar_config, status_bar_config]
    #         )
    #       end
    #
    #       def my_custom_navigation_config
    #         {
    #           :item_id => 'navigation',
    #           :region => :east,
    #           :width => 200
    #         }
    #       end
    #
    #       ...
    #     end
    #
    # The JS side of the component will have those regions referenced as this.mainPanel, this.statusBar, and this.menuBar.
    class SimpleApp < Base
      js_configure do |c|
        c.extend = "Ext.container.Viewport"
        c.layout = :border
        c.include Netzke::Core.ext_path.join("examples", "ux/statusbar/StatusBar.js"), :statusbar_ext
        c.mixin
      end

      def configure(c)
        super
        c.items = [main_panel_config, menu_bar_config, status_bar_config]
      end

      # In Ext 4.1 calling `render` on a viewport causes an error
      def js_component_render
        ""
      end

      # Override for custom menu
      def menu
        []
      end

      # Config for the main panel, which will contain dynamically loaded components.
      def main_panel_config(overrides = {})
        {
          :itemId => 'main_panel',
          :region => 'center',
          :layout => 'fit'
        }.merge(overrides)
      end

      # Config for the status bar
      def status_bar_config(overrides = {})
        {
          :itemId => 'status_bar',
          :xtype => 'statusbar',
          :region => 'south',
          :height => 22,
          :statusAlign => 'right',
          :busyText => 'Busy...',
          :default_text => "Ready",
          :default_icon_cls => ""
        }.merge(overrides)
      end

      # Config for the menu bar
      def menu_bar_config(overrides = {})
        {
          :itemId => 'menu_bar',
          :xtype => 'toolbar',
          :region => 'north',
          :height => 28,
          :items => menu
        }.merge(overrides)
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
