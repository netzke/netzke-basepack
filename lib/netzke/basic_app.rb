module Netzke
  #
  # Basis for a Ext.Viewport-based application
  #
  # Features:
  # * dynamic loading of widgets
  # * restoring of the last loaded widget (FIXME: not working for now)
  # * authentification support
  # * browser history support (press the "Back"-button to go to the previously loaded widget)
  # * FeedbackGhost-powered feedback
  # * hosting widget's own menus
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

      # Call appLoaded after the application is completely visible (e.g. load the initial widget, etc)
      def js_after_constructor
        <<-JS.l
          this.on("afterlayout", function(){this.appLoaded();}, this, {single:true});
        JS
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
        else
          res << "->" <<
          {
            :text => "Login",
            :handler => <<-JS.l,
              function(){
                window.location = "/login"
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
              var toolbar = this.findById('main-toolbar');
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
          
          # Loads widget by name
          :app_load_widget => <<-JS.l,
            function(name){
              Ext.History.add(name)
            }
          JS

          # Loads widget by action
          :load_widget_by_action => <<-JS.l
            function(action){
              this.appLoadWidget(action.widget || action.name)
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
      widget = params.delete(:widget).underscore
      persistent_config['last_loaded_widget'] = widget # store the last loaded widget in the persistent storage
      send("#{widget}__get_widget", params)
    end
    
  end
end