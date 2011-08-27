class WelcomeController < ApplicationController

  def index
    @components = @@component_list
  end

  def self.build_component_list
    list = Dir.glob(File.expand_path('../../components/*.rb', __FILE__)).map{ |name| File.basename(name, ".rb") }
    list.map { |name| name.classify.constantize rescue nil }.compact
  end

  @@component_list = build_component_list
end
