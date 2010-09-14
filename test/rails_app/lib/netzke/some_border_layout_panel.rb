module Netzke
  class SomeBorderLayoutPanel < Widget::BorderLayoutPanel
    def aggregatees
      {
        :center => {
          :class_name => "Panel",
          :html => "Center panel content"
        }
      }
    end
  end
end