module Netzke
  module Widget
    class Panel < Widget::Base

      def self.js_properties
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
end
