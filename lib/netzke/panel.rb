module Netzke
  class Panel < Base
    def self.js_extend_properties
      super.merge({
        :update_body_html => <<-JS.l,
          function(html){
            this.body.update(html);
          }
        JS
      })
    end
  end
end