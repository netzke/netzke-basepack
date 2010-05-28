# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeBasepackGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # FIXME: how do we avoid getting the same migration timestamps?
      # Work-around
      time = Time.now.utc.strftime("%Y%m%d%H%M%S")
      m.directory 'public/netzke/basepack'
      m.file 'public_assets/ts-checkbox.gif', "public/netzke/basepack/ts-checkbox.gif"
      
      m.directory 'db/migrate'
      # m.file 'create_netzke_layouts.rb', "db/migrate/#{time}_create_netzke_layouts.rb"
      m.file 'create_netzke_field_lists.rb', "db/migrate/#{time.to_i+1}_create_netzke_field_lists.rb"
      
    end
  end
end
