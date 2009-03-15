module Netzke
  class PropertyEditor < FormPanel
    # js_include %w{xcheckbox}.map{|name| "#{File.dirname(__FILE__)}/property_editor_extras/javascripts/#{name}.js"}
    
    def initialize(*args)
      super

      PropertyEditorExtras::HelperModel.widget_name = config[:widget_name]
      config[:data_class_name] = "Netzke::PropertyEditorExtras::HelperModel"
      config[:record] = PropertyEditorExtras::HelperModel.new
      config[:bbar] = %w{ apply }
      config[:persistent_layout] = false
    end

    def self.js_base_class
      FormPanel
    end
  end
end