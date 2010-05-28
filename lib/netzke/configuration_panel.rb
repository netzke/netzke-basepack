module Netzke
  # TabPanel-based widget that wraps-up "configuration widgets" that each widget can define 
  # (along) with including the Plugins::ConfigurationTool tool.
  class ConfigurationPanel < TabPanel
    api :commit
    def commit(params)
      commit_data = ActiveSupport::JSON.decode params[:commit_data]
      commit_data.each_pair do |k,v|
        aggregatee_instance(k).commit(v) if aggregatee_instance(k).respond_to?(:commit)
      end
      {:reload_parent => true, :feedback => (@flash.empty? ? nil : @flash)}
    end
    
    def self.js_extend_properties
      {
        :reload_parent => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.getParent().reload();
          }
        END_OF_JAVASCRIPT
      }
    end
  end
end