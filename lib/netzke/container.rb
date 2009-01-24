module Netzke
  #
  # Base class for Accordion and TabPanel widgets, it shouldn't be used as a stand-alone class.
  #
  class Container < Base
    def initialize(*args)
      super
      for item in initial_items do
        add_aggregatee item
        items << item.keys.first
      end
    end
    
    def initial_dependencies
      dep = super
      for item in items
        candidate_dependency = aggregatees[item][:widget_class_name]
        dep << candidate_dependency unless dep.include?(candidate_dependency)
      end
      dep
    end

    def self.js_before_constructor
      js_widget_items
    end
    
    def items
      @items ||= []
    end
    
    def initial_items
      config[:items] || []
    end
    
    def self.js_widget_items
      res = ""
      item_aggregatees.each_pair do |k,v|
        next if v[:late_aggregation]
        res << <<-JS
        var #{k.to_js} = new Ext.componentCache['#{v[:widget_class_name]}'](config.#{k.to_js}Config);
        JS
      end
      res
    end

    def self.js_items
      items.inject([]) do |a,i|
        a << {
          :title      => i.to_s.humanize,
          :layout     => 'fit',
          :id         => i.to_s,
          # :id       => "#{config[:name]}_#{i.to_s}",
          :items      => ([i.to_s.to_js.l] if !aggregatees[i][:late_aggregation]),
          # these listeners will be different for tab_panel and accordion
          :collapsed  => !aggregatees[i][:active],
          :listeners  => {
          # :activate => {:fn => "function(p){this.feedback(p.id)}".l, :scope => this},
          :expand     => {:fn => "this.loadItemWidget".l, :scope => this}
          }
        }
      end
    end
    
    def self.js_extend_properties
      {
        # loads widget into the panel if it's not loaded yet
        :load_item_widget => <<-JS.l,
          function(panel) {
            if (!panel.getWidget()) panel.loadWidget(this.id + "__" + panel.id + "__get_widget");
            // if (!this.getWidgetByPanel(panel)) this.loadWidget(panel, this.initialConfig[panel.id+'Config'].interface.getWidget);
          }
        JS
      }
    end

    protected
    def self.item_aggregatees
      aggregatees.delete_if{|k,v| !@items.include?(k)}
    end
  end
end