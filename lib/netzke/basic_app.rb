module Netzke
  #
  # Basis for a Ext.Viewport-based application
  #
  # Features:
  # * dynamic loading of widgets
  # * restoring of the last loaded widget (not working for now)
  # * authentification support
  # * browser history support (press the "Back"-button to go to the previously loaded widget)
  # * FeedbackGhost-powered feedback
  # * aggregation of widget's own menus
  #
  class BasicApp < Base
    # api :app_get_widget # to dynamically load the widgets that are defined in initial_late_aggregatees
    # api :load_widget
    
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
            :height => 25
          }]
        })
      end

      def js_after_constructor
        <<-JS.l
          // call appLoaded() once after the application is fully rendered
          // this.on("resize", function(){alert('show');this.appLoaded();}, this, {single:true});

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

          // add initial menus to the tool-bar
          var toolbar = this.findById('main-toolbar');
          Ext.each(#{js_initial_menus.to_nifty_json}, function(menu){
            toolbar.add(menu);
          });
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
              var toolbar = this.findById('main-toolbar');
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
                // this.findById('main-panel').loadWidget(this.initialConfig.api.appGetWidget, {widget:token})
                this.loadAggregatee({id:token, container:'main-panel'});
              } else {
                // this.findById('main-panel').loadWidget(null)
              }
            }
          JS
          
          :instantiate_aggregatee => <<-JS.l,
            function(config){
              this.findById('main-panel').instantiateChild(config);
            }
          JS
          
          # Loads widget by name
          :app_load_widget => <<-JS.l,
            function(name){
              Ext.History.add(name);
            }
          JS

          # Loads widget by action
          :load_widget_by_action => <<-JS.l
            function(action){
              this.appLoadWidget(action.widget || action.name);
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
    # def api_app_get_widget(params)
    #   widget = params.delete(:widget).underscore
    #   persistent_config['last_loaded_widget'] = widget # store the last loaded widget in the persistent storage
    #   send("#{widget}__get_widget", params)
    # end
   
    # def load_widget(params)
    #   load_aggregatee(params)
    #   # widget = aggregatee_instance(params[:widget])
    #   # 
    #   # {:this => [{:eval_js => widget.js_missing_code, :eval_css => css_missing_code}, {:instantiate_aggregatee => widget.js_config}]}
    # end

    # this should go into base_extras/api.rb
    # def load_aggregatee(params)
    #   widget = aggregatee_instance(params[:id])
    #   {:this => [{:eval_js => widget.js_missing_code, :eval_css => css_missing_code}, {:render_widget_in_container => {:container => params[:container], :config => widget.js_config}}]}
    # end
    
  end
end