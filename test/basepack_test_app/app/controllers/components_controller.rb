class ComponentsController < ApplicationController
  def index
    if params[:component]
      component_name = params[:component].gsub("::", "_").underscore
      if params[:spec]
        require 'active_record/fixtures'
        fixtures_dir = "../../spec/fixtures/#{params[:spec]}"
        Dir.glob(File.join(Rails.root, "#{fixtures_dir}/*.yml")).each do |fixture_file|
          ActiveRecord::Fixtures.reset_cache
          ActiveRecord::Fixtures.create_fixtures(File.join(Rails.root, fixtures_dir), File.basename(fixture_file, '.*'))
        end
      end
      render :inline => "<%= netzke :#{component_name}, :class_name => '#{params[:component]}', :height => 400 %>", :layout => true
    else
      redirect_to root_path
    end
  end
end
