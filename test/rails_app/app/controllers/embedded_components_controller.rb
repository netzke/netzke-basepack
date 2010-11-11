class EmbeddedComponentsController < ApplicationController
  # This will show a panel component with auto_load configured to get the content from the autoloaded_content action, which in its turn renders a component.
  # The trick is using the embedded_netzke layout.
  def index
  end

  def autoloaded_content
    render :inline => "<%= netzke :user_grid, :height => 300 %>", :layout => "embedded_netzke"
  end
end
