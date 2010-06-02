# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeBasepackGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory 'public/netzke/basepack'
      m.file 'public_assets/ts-checkbox.gif', "public/netzke/basepack/ts-checkbox.gif"

      m.migration_template 'create_netzke_field_lists.rb', 'db/migrate', :assigns => {
        :migration_name => "CreateNetzkeFieldLists"
      }, :migration_file_name => "create_netzke_field_lists"
    end
  end
end
