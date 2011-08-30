class WelcomeController < ApplicationController

  def index
    @components = @@component_list
  end

  # Build components list from basepack_test_app/app/components
  @@component_list ||= Dir.glob(File.expand_path('../../components/*.rb', __FILE__)).map{ |name| File.basename(name, ".rb") }.map(&:classify)
end
