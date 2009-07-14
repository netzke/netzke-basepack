module Netzke
  class ConfigurationPanel < TabPanel
    api :commit
    def commit(params)
      commit_data = ActiveSupport::JSON.decode params[:commit_data]
      commit_data.each_pair do |k,v|
        aggregatee_instance(k).commit(v)
      end
      {:this => {:reload_parent => true, :feedback => (@flash.empty? ? nil : @flash)}}
    end
    
    api :cancel
    def cancel(params)
      aggregatees.each_pair do |aggr, config|
        aggregatee_instance(aggr).cancel
      end
      {}
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