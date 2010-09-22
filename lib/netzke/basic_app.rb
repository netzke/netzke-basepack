module Netzke
  # == BasicApp
  # Basis for a Ext.Viewport-based application
  #
  # Features:
  # * dynamic loading of components
  # * authentification support
  # * browser history support (press the "Back"-button to go to the previously loaded component)
  # * FeedbackGhost-powered feedback
  # * handling component's own menus
  # * masquerade support
  # * AJAX activity indicator
  class BasicApp < Base
    def self.include_js
      res = []
      ext_examples = Netzke::Component::Base.config[:ext_location] + "/examples/"
      res << ext_examples + "ux/statusbar/StatusBar.js"
      res << "#{File.dirname(__FILE__)}/basic_app/statusbar_ext.js"
    end

    def self.js_base_class
      "Ext.Viewport"
    end

    # Global BasicApp configuration
    def self.config
      set_default_config({
        :logout_url => "/logout" # default logout url
      })
    end
    
    
    # def self.include_css
    #   res = []
    #   res << Netzke::Component::Base.config[:ext_location] + "/examples/ux/css/StatusBar.css"
    #   res
    # end
    
    def self.js_panels
      # In status bar we want to show what we are masquerading as
      if session[:masq_user]
        user = User.find(session[:masq_user])
        masq = %Q{user "#{user.login}"}
      elsif session[:masq_role]
        role = Role.find(session[:masq_role])
        masq = %Q{role "#{role.name}"}
      elsif session[:masq_world]
        masq = %Q{World}
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
      },{
        :id => 'main-statusbar',
        :xtype => 'statusbar',
        :region => 'south',
        :height => 22,
        :statusAlign => 'right',
        :busyText => 'Busy...',
        :default_text => masq.nil? ? "Ready #{"(config mode)" if session[:config_mode]}" : "Masquerading as #{masq}",
        :default_icon_cls => ""
      }]
    end
    
    def self.js_properties
      {
        :layout => 'border',

        :panels => js_panels,
        
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.items = this.panels; // a bit weird, but working; can't assign it straight
            
            #{js_full_class_name}.superclass.initComponent.call(this);

            // If we are given a token, load the corresponding component, otherwise load the last loaded component
            var currentToken = Ext.History.getToken();
            if (currentToken != "") {
              this.processHistory(currentToken);
            } else {
              var lastLoaded = this.initialConfig.componentToLoad; // passed from the server
              if (lastLoaded) Ext.History.add(lastLoaded);
            }

            Ext.History.on('change', this.processHistory, this);
            
            // Hosted menus
            this.menus = {};
            
            // Setting the "busy" indicator for Ajax requests
            Ext.Ajax.on('beforerequest', function(){this.findById('main-statusbar').showBusy()}, this);
            Ext.Ajax.on('requestcomplete', function(){this.findById('main-statusbar').hideBusy()}, this);
            Ext.Ajax.on('requestexception', function(){this.findById('main-statusbar').hideBusy()}, this);
            
            // Initialize history
            Ext.History.init();
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
          	toolbar.doLayout(); // required since Ext 3.0.3
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

        :on_login => <<-END_OF_JAVASCRIPT.l,
          function(){
            window.location = "/login"
          }
        END_OF_JAVASCRIPT
        
        :on_logout => <<-END_OF_JAVASCRIPT.l,
          function(){
            window.location = "#{config[:logout_url]}"
          }
        END_OF_JAVASCRIPT

        # Event handler for history change
        :process_history => <<-END_OF_JAVASCRIPT.l,
          function(token){
            if (token){
              this.loadComponent({id:token, container:'main-panel'});
            } else {
              Ext.getCmp('main-panel').removeChild();
            }
          }
        END_OF_JAVASCRIPT
        
        :instantiate_component => <<-END_OF_JAVASCRIPT.l,
          function(config){
            this.findById('main-panel').instantiateChild(config);
          }
        END_OF_JAVASCRIPT
        
        # Loads component by name
        :app_load_component => <<-END_OF_JAVASCRIPT.l,
          function(name){
            Ext.History.add(name);
          }
        END_OF_JAVASCRIPT

        # Loads component by action
        :load_component_by_action => <<-END_OF_JAVASCRIPT.l,
          function(action){
            this.appLoadComponent(action.component || action.name);
          }
        END_OF_JAVASCRIPT
        
        :on_toggle_config_mode => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.toggleConfigMode();
          }
        END_OF_JAVASCRIPT
        
        # NOT USED
        :show_login_window => <<-END_OF_JAVASCRIPT.l,
          function(){
            var w = new Ext.Window({
              title: "Please, login",
              modal: true,
              width: 350,
              height: 200,
              layout: 'fit',
              items: [{
                xtype: 'form',
                padding: 20,
                defaults: {anchor: '100%'},
                frame: true,
                border: false,
                items: [
                  {xtype: 'textfield', fieldLabel: 'Username', name: 'login'},
                  {name: 'password', xtype: 'textfield', inputType: 'password', fieldLabel: "Password"}
                ],
                buttons: [{
                  name: "submit",
                  text: "Login",
                  app: this,
                  handler: function() {
                    this.ownerCt.ownerCt.getForm().submit({
                      url: this.app.buildApiUrl("submit_login")
                    });
                  }
                }]
              }]
            });
            
            w.show();
          }
        END_OF_JAVASCRIPT
        
        
        # Masquerade selector window
        :show_masquerade_selector => <<-END_OF_JAVASCRIPT.l
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
                  if (role = w.getComponent().masquerade.role) {
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
                text:'As World',
                handler:function(){
                  Ext.Msg.confirm("Masquerading as World", "Caution! All settings that you will modify will be overwritten for all roles and all users. Are you sure you know what you're doing?", function(btn){
                    if (btn === "yes") {
                      this.masquerade = {world:true};
                      w.close();
                    }
                  }, this);
                },
                scope:this
              },{
                text:'No masquerading',
                handler:function(){
                  this.masquerade = {};
                  w.close();
                },
                scope:this
              },{
                text:'Cancel',
                handler:function(){
                  w.hide();
                },
                scope:this
              }],
              listeners : {close: {fn: function(){
                this.masqueradeAs(this.masquerade || w.getComponent().masquerade || {});
              }, scope: this}}
      			});

      			w.show(null, function(){
      			  this.loadComponent({id:"masqueradeSelector", container:w.id})
      			}, this);

          }
        END_OF_JAVASCRIPT
      }
    end
    
    # Set the Logout button if Netzke::Base.user is set
    def menu
      res = []
      user = User.find_by_id(session[:netzke_user_id])
      if !user.nil?
        user_name = user.respond_to?(:name) ? user.name : user.login # try to display user's name, fallback to login
        res << "->" <<
        {
          :text => "#{user_name}",
          :menu => user_menu
        }
      else
        res << "->" << :login
      end
      res
    end

    def user_menu
      [:logout]
    end

    def initialize(*args)
      super

      if session[:netzke_just_logged_in] || session[:netzke_just_logged_out]
        session[:config_mode] = false
        session[:masq_world] = session[:masq_user] = session[:masq_roles] = nil
      end

      strong_children_config.deep_merge!(:mode => :config) if session[:config_mode]
    end
    
    #
    # Available actions
    #
    def actions
      { 
        :masquerade_selector => {:text => "Masquerade as ...", :fn => "showMasqueradeSelector"},
        :toggle_config_mode => {:text => "#{session[:config_mode] ? "Leave" : "Enter"} config mode"},
        :login => {:text => "Login"},
        :logout => {:text => "Logout"}
      }
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
      session[:masq_world] = params[:world] == "true"
      session[:masq_role] = params[:role].try(:to_i)
      session[:masq_user] = params[:user].try(:to_i)
      {:js => "window.location.reload();"}
    end
    
    # Login request from the in-app login form
    api :submit_login
    def submit_login(params)
      # TODO: implement me
      {:feedback => "OK"}
    end
    
  end
end