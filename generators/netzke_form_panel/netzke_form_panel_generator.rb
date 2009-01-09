class NetzkeFormPanelGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'create_netzke_form_panel_fields.rb', "db/migrate", {:migration_file_name => "create_netzke_form_panel_fields"}
    end
  end
end
