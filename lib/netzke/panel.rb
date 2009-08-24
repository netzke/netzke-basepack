module Netzke
  class Panel < Base
    def self.js_extend_properties
      {
        :update_body_html => <<-END_OF_JAVASCRIPT.l,
          function(html){
            this.body.update(html);
          }
        END_OF_JAVASCRIPT
      }
    end
  end
end