module Netzke
  class PropertyEditor < FormPanel
    
    def initialize(*args)
      super
      PropertyEditorExtras::HelperModel.widget_name = config[:widget_name]
      @record = PropertyEditorExtras::HelperModel.new
    end

    def initial_config
      super.merge({
        :persistent_config => false,
        :persistent_layout => false,
        :bbar => false,
        :data_class_name => "Netzke::PropertyEditorExtras::HelperModel"
      })
    end

    def self.js_base_class
      FormPanel
    end
    
    def self.js_extend_properties
      super.merge({
        :get_commit_data => <<-JS.l
          function(){
            return this.form.getValues();
          }
        JS
      })
    end
    
    alias_method :commit, :create_or_update_record

    # To be compatible with the configuration panel
    def cancel
    end
  end
end