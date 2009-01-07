module Netzke
  class Wrapper < Base
    def self.js_default_config
      # make us an invisible 'fit'-layout panel
      super.merge({
        :layout => 'fit',
        :title => false,
        :border => false,
        :items => ["new Ext.componentCache[config.itemConfig.widgetClassName](config.itemConfig)".l]
      })
    end

    def initial_aggregatees
      item_name = config[:item][:name] ||= 'item'
      {item_name.to_sym => config[:item]}
    end
  end
  
end