module ApplicationHelper

  # Accepts a component class, returns the link to its code on github.
  def link_to_component_code(component)
    link_to("code", [RailsApp::Application.config.repo_root, "/app/components/", component.to_s.underscore, ".rb"].join)
  end

end
