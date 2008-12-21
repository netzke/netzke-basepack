class NetzkeGridGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'create_netzke_grid_columns.rb', "db/migrate", {:migration_file_name => "create_netzke_grid_columns"}
    end
  end
end
