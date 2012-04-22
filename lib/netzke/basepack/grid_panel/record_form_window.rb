module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class RecordFormWindow < Window

        component :add_form do |c|
          c.klass = FormPanel
          c.border = true
          c.bbar = false
          c.prevent_header = true
          c.merge! config.form_config
        end

        component :edit_form do |c|
          c.klass = FormPanel
          c.border = true
          c.bbar = false
          c.prevent_header = true
          c.merge! config.form_config
        end

        component :multi_edit_form do |c|
          c.klass = FormPanel
          c.border = true
          c.bbar = false
          c.prevent_header = true
          c.multi_edit = true
          c.merge! config.form_config
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

        def pre_configure_form(c)
        end
      end
    end
  end
end
