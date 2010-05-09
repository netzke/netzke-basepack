# class NetzkeCoreGenerator < Rails::Generator::NamedBase
class NetzkeBasepackGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # FIXME: how do we avoid getting the same migration timestamps?
      # Work-around
      time = Time.now.utc.strftime("%Y%m%d%H%M%S")
      m.directory 'public/netzke/basepack'
      m.file 'public_assets/ts-checkbox.gif', "public/netzke/basepack/ts-checkbox.gif"
    end
  end
end
