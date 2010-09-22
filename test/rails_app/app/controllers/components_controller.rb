class ComponentsController < ApplicationController
  def show
    component_name = params[:component].gsub("::", "__").underscore
    render :inline => "<%= netzke :#{component_name}, :class_name => '#{params[:component]}' %>", :layout => true
  end
end