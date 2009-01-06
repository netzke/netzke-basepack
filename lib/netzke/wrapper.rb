module Netzke
  class Wrapper < Base
    #
    # JS-class generation
    #
    class << self

      def js_default_config
        # make us an invisible 'fit'-layout panel
        super.merge({
          :layout => 'fit',
          :title => false,
          :border => false
        })
      end

    end
  
    def js_config
      super.merge(:items => items)
    end
  
    def initial_aggregatees
      item_name = config[:item][:name] ||= 'item'
      {item_name.to_sym => config[:item]}
    end

    def items
      item = config[:item]
      item_instance = Netzke::Base.instance_by_config(item.merge(:name => "#{id_name}__#{item[:name]}"))
      ["new Ext.componentCache['#{item[:widget_class_name]}'](#{item_instance.js_config.to_js})".l]
    end

  end
  
end