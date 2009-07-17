module Netzke
  class ConfigurationPanel < TabPanel
    api :commit
    def commit(params)
      commit_data = ActiveSupport::JSON.decode params[:commit_data]
      commit_data.each_pair do |k,v|
        aggregatee_instance(k).commit(v)
      end
      {:reload_parent => true, :feedback => (@flash.empty? ? nil : @flash)}
    end
    
    def self.js_extend_properties
      super.merge({
        :reload_parent => <<-JS.l,
          function(){
            this.getParent().reload();
          }
        JS
      })
    end
  end
end