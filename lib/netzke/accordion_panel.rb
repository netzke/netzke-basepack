module Netzke
  class AccordionPanel < Base
    #
    # JS-class generation
    #
    class << self

      def js_default_config
        super.merge({
          :layout => 'accordion',
          :listeners => {
            # every item gets an expand event activeted, which dynamically loads a widget into this item 
            :add => {
              :fn => <<-JS.l
              function(self, comp){
                comp.on('expand', this.loadItemWidget, self)
              }
              JS
            }
          }
        })
      end

      def js_extend_properties
        {
          # loads widget into the panel if it wasn't loaded yet
          :load_item_widget => <<-JS.l,
            function(panel) {
              if (!panel.getWidget()) panel.loadWidget(this.id + "__" + panel.id + "__get_widget");
            }
          JS
        }
      end

    end

    def js_config
      super.merge(:items => items)
    end

    # the items are late aggregatees (besides the ones that are marked "active")
    def initial_aggregatees
      res = {}
      config[:items].each_with_index do |item, i|
        item[:late_aggregation] = !item[:active]
        res.merge!(item[:name].to_sym => item)
      end
      res
    end

    def items
      res = []
      config[:items].each_with_index do |item, i|
        item_config = {
          :id => item[:name] || "item_#{i}",
          :title => item[:title] || (item[:name] && item[:name].humanize) || "Item #{i}",
          :layout => 'fit',
          :collapsed => !(item[:active] || false)
        }

        # directly embed the widget in the active panel
        if item[:active]
          item_instance = Netzke::Base.instance_by_config(item.merge(:name => "#{id_name}__#{item[:name]}"))
          item_config[:items] = ["new Ext.componentCache['#{item[:widget_class_name]}'](#{item_instance.js_config.to_js})".l]
        end
        
        res << item_config
      end
      res
    end
    
  end
end