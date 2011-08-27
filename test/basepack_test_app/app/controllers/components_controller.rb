class ComponentsController < ApplicationController
  def index
    if params[:component]
      component_name = params[:component].gsub("::", "_").underscore
      render :inline => "<%= netzke :#{component_name}, :class_name => '#{params[:component]}', :height => 400 %>", :layout => true
    else
      redirect_to root_path
    end
  end
end
