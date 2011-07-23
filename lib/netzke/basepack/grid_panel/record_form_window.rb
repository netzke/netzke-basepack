module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class RecordFormWindow < Window
        js_properties :button_align => "right"

        config :modal => true,
              :width => "50%",
              :auto_height => true,
              :fbar => [:ok.action, :cancel.action]

        action :ok do
          { :text => I18n.t('netzke.basepack.grid_panel.record_form_window.actions.ok')}
        end

        action :cancel do
          { :text => I18n.t('netzke.basepack.grid_panel.record_form_window.actions.cancel')}
        end

        js_method :init_component, <<-JS
          function(params){
            this.callParent();
            this.items.first().on("submitsuccess", function(){this.closeRes = "ok"; this.close();}, this);
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
      end
    end
  end
end