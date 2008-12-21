module Netzke
  #
  # Include this module into any widget if you want a "Properties" tool button in the top toolbar which will triggger a modal window, which will load the Accordion widgets, which in its turn will contain all the aggregatees specified in "property_widgets" method (*must* be defined)
  #
  module PropertiesTool
    def self.included(base)
      base.class_eval do
        [:js_extend_properties, :tools, :initial_aggregatees].each{ |m| alias_method_chain m, :properties }
      end

      # if you include PropertiesTool, you must define property_widgets method which will returns an array of arrgeratees that will be included in the property window (each in its own tab or accordion pane)
      raise "property_widgets method undefined" unless base.instance_methods.include?("property_widgets")
    end

    def initial_aggregatees_with_properties
      res = initial_aggregatees_without_properties
      # Add the accordion as aggregatee, with in its turn aggregates widgets from the property_widgets method
      res.merge!(:properties => {:widget_class_name => 'Accordion', :items => property_widgets, :ext_config => {:title => false}, :no_caching => true, :late_aggregation => true}) unless config[:ext_config][:properties] == false
      res
    end

    def tools_with_properties
      tools = tools_without_properties
      # Add the toolbutton
      tools << {:id => 'gear', :on => {:click => "showConfig"}} unless config[:ext_config] && config[:ext_config][:properties] == false
      tools
    end
  
    def js_extend_properties_with_properties
      js_extend_properties_without_properties.merge({
        :show_config => <<-JS.l
          function(){
            var w = new Ext.Window({
              title:'Config',
              layout:'fit',
      				modal:true,
              width:window.innerWidth*.9,
              height:window.innerHeight*.9,
      	      closeAction:'destroy',
      	      buttons:[{
      	        text:'Submit',
      	        handler:function(){this.ownerCt.closeRes = 'OK'; this.ownerCt.destroy()}
      	      }]

      			});
          
      			w.show(null, function(){
              w.loadWidget(this.initialConfig.id+"__properties__get_widget");
      			}, this);

      			w.on('destroy', function(){
      			  if (w.closeRes == 'OK'){
                widget = this;
      			    if (widget.ownerCt) {
                  widget.ownerCt.loadWidget(widget.initialConfig.interface.getWidget);
                } else {
                  this.feedback('Reload current window') // no aggregation
                }
      			  }
      			}, this)
          }
        JS
      })
    end
  end
end