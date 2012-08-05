module Netzke
  module Basepack
    class Panel < Netzke::Base
      js_configure do |c|
        c.update_body_html = <<-JS
          function(html){
            this.body.update(html);
          }
        JS
      end
    end
  end
end
