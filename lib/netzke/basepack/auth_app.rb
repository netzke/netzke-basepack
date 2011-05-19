module Netzke
  module Basepack
    # Extension to SimpleApp that brings in support for authentication and masquerading
    # ** NOTE: it's WIP **
    class AuthApp < SimpleApp

      class_attribute :login_url
      self.login_url = "/login"

      class_attribute :logout_url
      self.logout_url = "/logout"

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

      js_method :on_toggle_config_mode, <<-JS
        function(params){
          this.toggleConfigMode();
        }
      JS
# WIP: todo - rewrite Ext.lib calls below
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
