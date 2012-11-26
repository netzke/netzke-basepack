module Netzke
  module Basepack
    module GridLib
      class RecordFormWindow < Netzke::Basepack::Window

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

        def configure(c)
          super
          c.fbar = [:ok, :cancel]
        end

        js_configure do |c|
          c.button_align = :right
          c.width = 400
          c.auto_height = true
          c.modal = true
          c.init_component = <<-JS
            function(params){
              this.callParent();
              this.items.first().on("submitsuccess", function(){ this.closeRes = "ok"; this.close(); }, this);
            }
          JS

          c.on_ok = <<-JS
            function(params){
              this.items.first().onApply();
            }
          JS

          c.on_cancel = <<-JS
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
          c.klass = Form
          c.border = true
          c.bbar = false
          c.prevent_header = true
          c.merge! config.form_config
        end
      end
    end
  end
end
