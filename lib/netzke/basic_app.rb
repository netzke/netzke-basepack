module Netzke
  # == BasicApp
  # Basis for a Ext.Viewport-based application
  #
  # Features:
  # * dynamic loading of widgets
  # * authentification support
  # * browser history support (press the "Back"-button to go to the previously loaded widget)
  # * FeedbackGhost-powered feedback
  # * aggregation of widget's own menus
  # * masquerade support
  # * AJAX activity indicator
  class BasicApp < Base
    module ClassMethods

      def js_base_class
        "Ext.Viewport"
      end

      # Global BasicApp configuration
      def config
        set_default_config({
          :logout_url => "/logout" # default logout url
        })
      end
      
      def js_panels
        # In status bar we want to show what we are masquerading as
        if session[:masq_user]
          user = User.find(session[:masq_user])
          masq = %Q{user "#{user.login}"}
        elsif session[:masq_role]
          role = Role.find(session[:masq_role])
          masq = %Q{role "#{role.name}"}
        end
                
        [{
          :id => 'main-panel',
          :region => 'center',
          :layout => 'fit'
        },{
          :id => 'main-toolbar',
          :xtype => 'toolbar',
          :region => 'north',
          :height => 25
          # :items => ["-"]
        },{
          :id => 'main-statusbar',
          :xtype => 'statusbar',
          :region => 'south',
          :statusAlign => 'right',
          :busyText => 'Busy...',
          :default_text => masq.nil? ? "Ready #{"(config mode)" if session[:config_mode]}" : "Masquerading as #{masq}",
          :default_icon_cls => ""
        }]
      end
      
      def js_extend_properties
        {
          :layout => 'border',

          :panels => js_panels,
          
          :init_component => <<-END_OF_JAVASCRIPT.l,
            function(){
              this.items = this.panels; // a bit weird, but working; can't assign it straight
              
              Ext.netzke.cache.BasicApp.superclass.initComponent.call(this);

              // If we are given a token, load the corresponding widget, otherwise load the last loaded widget
              var currentToken = Ext.History.getToken();
              if (currentToken != "") {
                this.processHistory(currentToken)
              } else {
                var lastLoaded = this.initialConfig.widgetToLoad; // passed from the server
                if (lastLoaded) Ext.History.add(lastLoaded);
              }

              Ext.History.on('change', this.processHistory, this);
              
              // Hosted menus
              this.menus = {};
              
              // Setting the "busy" indicator for Ajax requests
              Ext.Ajax.on('beforerequest', function(){this.findById('main-statusbar').showBusy()}, this);
              Ext.Ajax.on('requestcomplete', function(){this.findById('main-statusbar').hideBusy()}, this);
              Ext.Ajax.on('requestexception', function(){this.findById('main-statusbar').hideBusy()}, this);
            }
          END_OF_JAVASCRIPT
          
          :host_menu => <<-END_OF_JAVASCRIPT.l,
            function(menu, owner){
              var toolbar = this.findById('main-toolbar');
              if (!this.menus[owner.id]) this.menus[owner.id] = [];
              Ext.each(menu, function(item) {
                // var newMenu = new Ext.Toolbar.Button(item);
                // var position = toolbar.items.getCount() - 2;
                // position = position < 0 ? 0 : position;
                // toolbar.insertButton(position, newMenu);

                toolbar.add(item);
                // this.menus[owner.id].push(newMenu); // TODO: remember the menus from this owner in some other way
            	}, this);
          	}
          END_OF_JAVASCRIPT

          :unhost_menu => <<-END_OF_JAVASCRIPT.l,
            function(owner){
              // var toolbar = this.findById('main-toolbar');
              // if (this.menus[owner.id]) {
              //   Ext.each(this.menus[owner.id], function(menu){
              //     toolbar.items.remove(menu); // remove the item from the toolbar
              //     menu.destroy(); // ... and destroy it
              //   });
              // }
            }
          END_OF_JAVASCRIPT

          :logout => <<-END_OF_JAVASCRIPT.l,
            function(){
              window.location = "#{config[:logout_url]}"
            }
          END_OF_JAVASCRIPT

          # Event handler for history change
          :process_history => <<-END_OF_JAVASCRIPT.l,
            function(token){
              if (token){
                this.loadAggregatee({id:token, container:'main-panel'});
              } else {
              }
            }
          END_OF_JAVASCRIPT
          
          :instantiate_aggregatee => <<-END_OF_JAVASCRIPT.l,
            function(config){
              this.findById('main-panel').instantiateChild(config);
            }
          END_OF_JAVASCRIPT
          
          # Loads widget by name
          :app_load_widget => <<-END_OF_JAVASCRIPT.l,
            function(name){
              Ext.History.add(name);
            }
          END_OF_JAVASCRIPT

          # Loads widget by action
          :load_widget_by_action => <<-END_OF_JAVASCRIPT.l,
            function(action){
              this.appLoadWidget(action.widget || action.name);
            }
          END_OF_JAVASCRIPT
          
          # Masquerade selector window
          :show_masquerade_selector => <<-END_OF_JAVASCRIPT.l,
            function(){
              var w = new Ext.Window({
        				title: 'Masquerade as',
        				modal: true,
        				width: Ext.lib.Dom.getViewWidth() * 0.6,
                height: Ext.lib.Dom.getViewHeight() * 0.6,
                layout: 'fit',
        	      closeAction :'destroy',
                buttons: [{
                  text: 'Select',
                  handler : function(){
                    if (role = w.getWidget().masquerade.role) {
                      Ext.Msg.confirm("Masquerading as a role", "Individual preferences for all users with this role will get overwritten as you make changes. Continue?", function(btn){
                        if (btn === 'yes') {
                          w.close();
                        }
                      });
                    } else {
                      w.close();
                    }
                  },
                  scope:this
                },{
                  text:'Turn off masquerading',
                  handler:function(){
                    this.masquerade = {};
                    w.close();
                  },
                  scope:this
                },{
                  text:'Cansel',
                  handler:function(){
                    w.hide();
                  },
                  scope:this
                }],
                listeners : {close: {fn: function(){
                  this.masqAs(this.masquerade || w.getWidget().masquerade || {});
                }, scope: this}}
        			});

        			w.show(null, function(){
        			  this.loadAggregatee({id:"masqueradeSelector", container:w.id})
        			}, this);

            }
          END_OF_JAVASCRIPT

          # Masquerade as...
          :masq_as => <<-END_OF_JAVASCRIPT.l
            function(masqConfig){
              params = {};

              if (masqConfig.user) {
                params.user = masqConfig.user
              }

              if (masqConfig.role) {
                params.role = masqConfig.role
              }

              this.masqueradeAs(params);

            }
          END_OF_JAVASCRIPT
        }
      end
    end
    
    extend ClassMethods
        
    # Set the Logout button if Netzke::Base.user is set
    def menu
      res = []
      user = Netzke::Base.user
      if !user.nil?
        user_name = user.respond_to?(:name) ? user.name : user.login # try to display user's name, fallback to login
        res << "->" <<
        {
          :text => "#{user_name}",
          :menu => user_menu
        }
      else
        res << "->" <<
        {
          :text => "Login",
          :handler => <<-END_OF_JAVASCRIPT.l,
            function(){
              window.location = "/login"
            }
          END_OF_JAVASCRIPT
          :scope => this
        }
      end
      res
    end

    def user_menu
      ['logout']
    end

    def initialize(*args)
      super

      if session[:netzke_just_logged_in] || session[:netzke_just_logged_out]
        session[:config_mode] = false
        session[:masq_user] = session[:masq_roles] = nil
      end

      strong_children_config.deep_merge!({:ext_config => {:mode => :config}}) if session[:config_mode]
    end
    
    #
    # Available actions
    #
    def actions
      { 
        :masquerade_selector => {:text => "Masquerade as ...", :fn => "showMasqueradeSelector"},
        :toggle_config_mode => {:text => "#{session[:config_mode] ? "Leave" : "Enter"} config mode", :fn => "toggleConfigMode"},
        :logout => {:text => "Log out", :fn => "logout"}
      }
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
      <<-END_OF_JAVASCRIPT << super
        new Ext.netzke.cache['FeedbackGhost']({id:'feedback_ghost'})
        // Initialize history (can't say why it's not working well inside the appLoaded handler)
        Ext.History.init();
      END_OF_JAVASCRIPT
    end

    #
    # Interface section
    #
    
    api :toggle_config_mode
    def toggle_config_mode(params)
      session = Netzke::Base.session
      session[:config_mode] = !session[:config_mode]
      {:js => "window.location.reload();"}
    end

    api :masquerade_as
    def masquerade_as(params)
      session = Netzke::Base.session
      session[:masq_role] = params[:role]
      session[:masq_user] = params[:user]
      {:js => "window.location.reload()"}
    end
    
  end
end