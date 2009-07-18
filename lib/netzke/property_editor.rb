module Netzke
  class PropertyEditor < FormPanel
    
    def initialize(*args)
      super
      PropertyEditorExtras::HelperModel.widget = config[:widget]
      @record = PropertyEditorExtras::HelperModel.new
    end

    def default_config
      super.recursive_merge({
        :persistent_config => false,
        :bbar => [],
        :data_class_name => "Netzke::PropertyEditorExtras::HelperModel"
      })
    end
    
    def self.js_default_config
      super.recursive_merge({
        :label_width => 200
      })
    end

    def self.js_base_class
      "Ext.form.FormPanel"
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

  end
end