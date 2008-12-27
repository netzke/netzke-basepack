# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{netzke_core}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sergei Kozlov"]
  s.date = %q{2008-12-27}
  s.description = %q{Base Netzke widgets - grid, form, tree, and more}
  s.email = %q{sergei@writelesscode.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/app/models/netzke_grid_column.rb", "lib/netzke/accordion.rb", "lib/netzke/ar_ext.rb", "lib/netzke/column.rb", "lib/netzke/container.rb", "lib/netzke/grid.rb", "lib/netzke/grid_interface.rb", "lib/netzke/grid_js_builder.rb", "lib/netzke/preference_grid.rb", "lib/netzke/properties_tool.rb", "lib/netzke/property_grid.rb", "lib/netzke_basepack.rb", "LICENSE", "README.mdown", "tasks/netzke_basepack_tasks.rake"]
  s.files = ["CHANGELOG", "generators/netzke_basepack/netzke_basepack_generator.rb", "generators/netzke_basepack/netzke_grid_generator.rb", "generators/netzke_basepack/templates/create_netzke_grid_columns.rb", "generators/netzke_basepack/USAGE", "init.rb", "install.rb", "javascripts/basepack.js", "lib/app/models/netzke_grid_column.rb", "lib/netzke/accordion.rb", "lib/netzke/ar_ext.rb", "lib/netzke/column.rb", "lib/netzke/container.rb", "lib/netzke/grid.rb", "lib/netzke/grid_interface.rb", "lib/netzke/grid_js_builder.rb", "lib/netzke/preference_grid.rb", "lib/netzke/properties_tool.rb", "lib/netzke/property_grid.rb", "lib/netzke_basepack.rb", "LICENSE", "Rakefile", "README.mdown", "tasks/netzke_basepack_tasks.rake", "test/app_root/app/controllers/application.rb", "test/app_root/app/models/book.rb", "test/app_root/app/models/category.rb", "test/app_root/app/models/city.rb", "test/app_root/app/models/continent.rb", "test/app_root/app/models/country.rb", "test/app_root/app/models/genre.rb", "test/app_root/config/boot.rb", "test/app_root/config/database.yml", "test/app_root/config/environment.rb", "test/app_root/config/environments/in_memory.rb", "test/app_root/config/environments/mysql.rb", "test/app_root/config/environments/postgresql.rb", "test/app_root/config/environments/sqlite.rb", "test/app_root/config/environments/sqlite3.rb", "test/app_root/config/routes.rb", "test/app_root/db/migrate/20081222033343_create_books.rb", "test/app_root/db/migrate/20081222033440_create_genres.rb", "test/app_root/db/migrate/20081222035855_create_netzke_preferences.rb", "test/app_root/db/migrate/20081223024935_create_categories.rb", "test/app_root/db/migrate/20081223025635_create_countries.rb", "test/app_root/db/migrate/20081223025653_create_continents.rb", "test/app_root/db/migrate/20081223025732_create_cities.rb", "test/app_root/script/console", "test/app_root/vendor/plugins/netzke_core", "test/ar_ext_test.rb", "test/column_test.rb", "test/console_with_fixtures.rb", "test/fixtures/books.yml", "test/fixtures/categories.yml", "test/fixtures/cities.yml", "test/fixtures/continents.yml", "test/fixtures/countries.yml", "test/fixtures/genres.yml", "test/grid_test.rb", "test/netzke_basepack_test.rb", "test/schema.rb", "test/test_helper.rb", "uninstall.rb", "Manifest", "netzke_core.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://writelesscode.com}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Netzke_core", "--main", "README.mdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{netzke_core}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Base Netzke widgets - grid, form, tree, and more}
  s.test_files = ["test/ar_ext_test.rb", "test/column_test.rb", "test/grid_test.rb", "test/netzke_basepack_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<searchlogic>, [">= 1.6.2"])
      s.add_runtime_dependency(%q<netzke_core>, [">= 0", "= 0.1.0"])
    else
      s.add_dependency(%q<searchlogic>, [">= 1.6.2"])
      s.add_dependency(%q<netzke_core>, [">= 0", "= 0.1.0"])
    end
  else
    s.add_dependency(%q<searchlogic>, [">= 1.6.2"])
    s.add_dependency(%q<netzke_core>, [">= 0", "= 0.1.0"])
  end
end
