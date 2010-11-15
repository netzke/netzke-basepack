module Netzke
  module Basepack
    # == BasicApp
    # Basis for a Ext.Viewport-based application
    #
    # Features:
    # * dynamic loading of components
    # * browser history support (press the "Back"-button to go to the previously loaded component)
    # * AJAX activity indicator
    # * (TODO) authentification support
    # * (TODO) masquerade support
    class BasicApp < Base

      js_base_class "Ext.Viewport"

      js_property :layout, :border

      def self.include_js
        res = []
        ext_examples = Netzke::Core.ext_location.join("examples")
        res << ext_examples.join("ux/statusbar/StatusBar.js")
        res << "#{File.dirname(__FILE__)}/basic_app/statusbar_ext.js"
      end

      class_attribute :login_url
      self.login_url = "/login"

      class_attribute :logout_url
      self.logout_url = "/logout"

      config do
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

        {
          :items => [{
            :id => 'main-panel',
            :region => 'center',
            :layout => 'fit'
          },{
            :id => 'main-toolbar',
            :xtype => 'toolbar',
            :region => 'north',
            :height => 25,
            :items => menu
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
        }
      end

      js_method :init_component, <<-JS
        function(){
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

          // Setting the "busy" indicator for Ajax requests
          Ext.Ajax.on('beforerequest', function(){this.findById('main-statusbar').showBusy()}, this);
          Ext.Ajax.on('requestcomplete', function(){this.findById('main-statusbar').hideBusy()}, this);
          Ext.Ajax.on('requestexception', function(){this.findById('main-statusbar').hideBusy()}, this);

          // Initialize history
          Ext.History.init();
        }
      JS

      js_method :on_login, <<-JS
        function(){
          window.location = "#{login_url}"
        }
      JS

      js_method :on_logout, <<-JS
        function(){
          window.location = "#{logout_url}"
        }
      JS

      js_method :process_history, <<-JS
        function(token){
          if (token){
            this.loadComponent({name:token, container:'main-panel'});
          } else {
            Ext.getCmp('main-panel').removeChild();
          }
        }
      JS

      js_method :instantiate_component, <<-JS
        function(config){
          this.findById('main-panel').instantiateChild(config);
        }
      JS

      js_method :app_load_component, <<-JS
        function(name){
          Ext.History.add(name);
        }
      JS

      js_method :load_component_by_action, <<-JS
        function(action){
          this.appLoadComponent(action.component || action.name);
        }
      JS

      js_method :on_toggle_config_mode, <<-JS
        function(params){
          this.toggleConfigMode();
        }
      JS

      js_method :show_masquerade_selector, <<-JS
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
                if (role = w.getNetzkeComponent().masquerade.role) {
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
              this.masqueradeAs(this.masquerade || w.getNetzkeComponent().masquerade || {});
            }, scope: this}}
    			});

    			w.show(null, function(){
    			  this.loadComponent({id:"masqueradeSelector", container:w.id})
    			}, this);

        }
      JS

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
          res << "->" << :login.action
        end
        res
      end

      def user_menu
        [:logout.action]
      end

      def initialize(*args)
        super

        if session[:netzke_just_logged_in] || session[:netzke_just_logged_out]
          session[:config_mode] = false
          session[:masq_world] = session[:masq_user] = session[:masq_roles] = nil
        end

        strong_children_config.deep_merge!(:mode => :config) if session[:config_mode]
      end


      action :masquerade_selector, :text => "Masquerade as ...", :handler => :show_masquerade_selector

      action :toggle_config_mode do
        {:text => "#{session[:config_mode] ? "Leave" : "Enter"} config mode"}
      end

      action :login, :icon => :door_in

      action :logout, :icon => :door_out

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
      endpoint :toggle_config_mode do |params|
        session = Netzke::Base.session
        session[:config_mode] = !session[:config_mode]
        {:js => "window.location.reload();"}
      end

      endpoint :masquerade_as do |params|
        session = Netzke::Base.session
        session[:masq_world] = params[:world] == "true"
        session[:masq_role] = params[:role].try(:to_i)
        session[:masq_user] = params[:user].try(:to_i)
        {:js => "window.location.reload();"}
      end

    end
  end
end
