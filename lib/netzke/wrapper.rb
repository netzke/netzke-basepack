module Netzke
  class Wrapper < Base
    def self.js_common_config_for_constructor
      # make us an invisible 'fit'-layout panel
      super.merge({
        :layout => 'fit',
        :title  => false,
        :border => false,
        :items  => ["new Ext.netzke.cache[config.itemConfig.widgetClassName](config.itemConfig)".l]
      })
    end

    def initial_aggregatees
      {:item => config[:item]}
    end
  end
  
end