module Netzke
  class Accordion < Container

    def js_default_config
      super.merge({
        :layout => 'accordion'
      })
    end
    
  end
end