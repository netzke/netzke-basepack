module Netzke
  #
  # Basis for a Ext.Viewport-based application
  #
  # Features:
  # * dynamic loading of widgets
  # * restoring of the last loaded widget
  # * authentification support
  # * browser history support (press the "Back"-button to go to the previously loaded widget)
  # * FeedbackGhost-powered feedback
  # * aggregation of widget's own menus (TODO: coming soon)
  #
  class BasicApp < Base
    interface :app_get_widget # to dynamically load the widgets that are defined in initial_late_aggregatees
    
    module ClassMethods

      def js_base_class
        "Ext.Viewport"
      end

      # Global BasicApp configuration
      def config
        set_default_config({
            :logout_url => "/logout" # logout url assumed by default
        })
      end
      
      # The layout
      def js_default_config
        super.merge({
          :layout => 'border',
          :items => [{
            :id => 'main-panel',
            :region => 'center',
            :layout => 'fit'
          },{
      			:id => 'main-toolbar',
      			:xtype => 'toolbar',
            :region => 'north',
            :height => 25,
      			:items => js_initial_menus
          }]
        })
      end

      # Set the event to do some things after the application is completely visible (e.g. to load the initial widget)
      def js_listeners
        {:afterlayout => {:fn => "this.onAfterLayout".l, :scope => this}}
      end
      
      # Set the Logout button if Netzke::Base.user is set
      def js_initial_menus
        res = []
        user = Netzke::Base.user
        if !user.nil?
          user_name = user.respond_to?(:name) ? user.name : user.login # try to display user's name, fallback to login
          res << "->" <<
          {
            :text => "Logout #{user_name}",
            :handler => <<-JS.l,
              function(){
                Ext.MessageBox.confirm('Confirm', 'Are you sure you want to logout?', function(btn){
    							if( btn == "yes" ) {
    								this.logout();
    							}
    						}.createDelegate(this));
              }
            JS
  			    :scope => this
          }
        end
        res
      end
      
      def js_extend_properties
        super.merge({

          # Initialize
          :app_loaded => <<-JS.l,
          function(){
            // Initialize menus (upcoming support for dynamically loaded menus)
            this.menus = {};
            
            Ext.History.on('change', this.processHistory, this);

            // If we are given a token, load the corresponding widget, otherwise load the last loaded widget
            var currentToken = Ext.History.getToken();
            if (currentToken != "") {
              this.processHistory(currentToken)
            } else {
              var lastLoaded = this.initialConfig.widgetToLoad; // passed from the server
              if (lastLoaded) Ext.History.add(lastLoaded);
            }
            
            if (this.initialConfig.menu) {this.addMenu(this.initialConfig.menu, this);}
          }
          JS
          
          :host_menu => <<-JS.l,
            function(menu, owner){
              var toolbar = this.getComponent('main-toolbar');
              if (!this.menus[owner.id]) this.menus[owner.id] = [];
              Ext.each(menu, function(item) {
            	  var newMenu = new Ext.Toolbar.Button(item);
            	  var position = toolbar.items.getCount() - 2;
            	  position = position < 0 ? 0 : position;
            	  toolbar.insertButton(position, newMenu);
            	  this.menus[owner.id].push(newMenu);
            	}, this);
          	}
          JS

          :unhost_menu => <<-JS.l,
            function(owner){
              var toolbar = this.getComponent('main-toolbar');
              if (this.menus[owner.id]) {
                Ext.each(this.menus[owner.id], function(menu){
                  toolbar.items.remove(menu); // remove the item from the toolbar
                  menu.destroy(); // ... and destroy it
                });
              }
            }
          JS

          :logout => <<-JS.l,
            function(){
              window.location = "#{config[:logout_url]}"
            }
          JS

          # Work around to fire "appLoaded" event only once
          :on_after_layout => <<-JS.l,
            function(){
              this.un('afterlayout', this.onAfterLayout, this); // avoid multiple calls
              this.appLoaded();
            }
          JS

          # Event handler for history change
          :process_history => <<-JS.l,
            function(token){
              if (token){
                Ext.getCmp('main-panel').loadWidget(this.initialConfig.interface.appGetWidget, {widget:token})
              } else {
                Ext.getCmp('main-panel').loadWidget(null)
              }
            }
          JS
          
          #
          # Set this function as the event handler for your menus, e.g.:
          #
          #     :menu => {
          #      :items => [{
          #        :text => "Books",
          #        :handler => "this.appLoadWidget".l,
          #        :widget => 'books', # specify here the name of the widget to be loaded
          #        :scope => this
          #      }]
          #     }
          #
          :app_load_widget => <<-JS.l
          function(menuItem){
            Ext.History.add(menuItem.widget)
          }
          JS

        })
      end
    end
    
    extend ClassMethods
    
    # Pass the last loaded widget from the persistent storage (DB) to the browser
    def js_config
      super.merge({:widget_to_load => persistent_config['last_loaded_widget']})
    end
    
    # Html required for Ext.History to work
    def js_widget_html
      super << %Q{
<form id="history-form" class="x-hidden">
    <input type="hidden" id="x-history-field" />
    <iframe id="x-history-frame"></iframe>
</form>
      }
    end

    # We rely on the FeedbackGhost (to not need to implement our own feedback management)
    def initial_aggregatees
      {:feedback_ghost => {:widget_class_name => "FeedbackGhost"}}
    end

    # Besides instantiating ourselves, also instantiate the FeedbackGhost
    def js_widget_instance
      %Q{
        new Ext.netzke.cache['FeedbackGhost']({id:'feedback_ghost'})
        // Initialize history (can't say why it's not working well inside the appLoaded handler)
        Ext.History.init();
      } << super
    end
    
    # Interface implementation
    def interface_app_get_widget(params)
      widget = params.delete(:widget)
      persistent_config['last_loaded_widget'] = widget # store the last loaded widget in the persistent storage
      send("#{widget}__get_widget", params)
    end
    
  end
end