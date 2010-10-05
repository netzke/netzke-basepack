module Netzke
  module Basepack
    class Panel < Component::Base
      js_method :update_body_html, <<-JS
        function(html){
          this.body.update(html);
        }
      JS
    end
  end
end
