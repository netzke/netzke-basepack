module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class RecordFormWindow < Window

        component :add_form do |c|
          preconfigure_form(c)
        end

        component :edit_form do |c|
          preconfigure_form(c)
        end

        component :multi_edit_form do |c|
          preconfigure_form(c)
          c.multi_edit = true
        end

        def configure
          super
          config.fbar = [:ok, :cancel]
        end

        js_properties :button_align => :right,
                      :width => 400,
                      :auto_height => true,
                      :modal => true

        action :ok do |a|
          a.text = I18n.t('netzke.basepack.grid_panel.record_form_window.actions.ok')
        end

        action :cancel do |a|
          a.text = I18n.t('netzke.basepack.grid_panel.record_form_window.actions.cancel')
        end

        js_method :init_component, <<-JS
          function(params){
            this.callParent();
            this.items.first().on("submitsuccess", function(){ this.closeRes = "ok"; this.close(); }, this);
          }
        JS

        js_method :on_ok, <<-JS
          function(params){
            this.items.first().onApply();
          }
        JS

        js_method :on_cancel, <<-JS
          function(params){
            this.close();
          }
        JS

      private

        def preconfigure_form(c)
          c.klass = FormPanel
          c.border = true
          c.bbar = false
          c.prevent_header = true
          c.merge! config.form_config
        end
      end
    end
  end
end
