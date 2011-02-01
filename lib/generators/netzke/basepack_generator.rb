module Netzke
  class BasepackGenerator < ::Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Copies necessary assets to public/netzke/basepack'
    def execute
      copy_file 'assets/ts-checkbox.gif', "public/netzke/basepack/ts-checkbox.gif"
    end
  end
end