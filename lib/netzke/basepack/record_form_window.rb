module Netzke
  module Basepack
    class RecordFormWindow < Netzke::Window::Base
      def configure(c)
        super
        c.fbar = [:ok, :cancel]
      end

      component :add_form do |c|
        preconfigure_form(c)
      end

      component :edit_form do |c|
        preconfigure_form(c)
        c.record_id = config.client_config[:record_id]
      end

      component :multiedit_form do |c|
        preconfigure_form(c)
        c.multiedit = true
      end

      client_class do |c|
        c.button_align = :right
        c.width = '80%'
        c.auto_height = true
        c.modal = true
        c.init_component = l(<<-JS)
          function(params){
            this.callParent();
            this.items.first().on("submitsuccess", function(){ this.closeRes = "ok"; this.close(); }, this);
          }
        JS

        c.netzke_on_ok = l(<<-JS)
          function(params){
            this.items.first().netzkeOnApply();
          }
        JS

        c.netzke_on_cancel = l(<<-JS)
          function(params){
            this.close();
          }
        JS
      end

      action :ok

      action :cancel

    protected

      def self.server_side_config_options
        [:form_config, *super]
      end

      def preconfigure_form(c)
        c.klass = Netzke::Form::Base
        c.border = true
        c.bbar = false
        c.prevent_header = true
        c.merge! config.form_config
      end
    end
  end
end
