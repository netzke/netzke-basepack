module Netzke
  # Include this module into any widget where you want a "gear" tool button in the top toolbar 
  # which will triggger a modal window, which will load the ConfigurationPanel TabPanel-based 
  # widget, which in its turn will contain all the aggregatees specified in "configuration_widgets" 
  # method (which *must* be defined)
  
  module ConfigurationTool
    def self.included(base)
      base.extend ClassMethods
      
      base.class_eval do
        # replacing instance methods
        [:tools, :initial_aggregatees].each{ |m| alias_method_chain m, :config_tool }
        
        # API to commit the changes
        api :commit

        # replacing class methods
        class << self
          alias_method_chain :js_extend_properties, :config_tool
        end
      end

      # if you include ConfigurationTool, you must define configuration_widgets method which will returns an array of arrgeratees that will be included in the property window (each in its own tab or accordion pane)
      raise "configuration_widgets method undefined" unless base.instance_methods.include?("configuration_widgets")
    end

    module ClassMethods
      def js_extend_properties_with_config_tool
        js_extend_properties_without_config_tool.merge({
          :gear => <<-JS.l
            function(){
              var w = new Ext.Window({
                title:'Config',
                layout:'fit',
                modal:true,
                width: Ext.lib.Dom.getViewWidth() *0.9,
                height: Ext.lib.Dom.getViewHeight() *0.9,
                closeAction:'destroy',
                buttons:[{
                  text:'OK',
                  handler:function(){
                    this.ownerCt.closeRes = 'OK'; 
                    this.ownerCt.close();
                  }
                },{
                  text:'Cancel',
                  handler:function(){
                    this.ownerCt.closeRes = 'cancel'; 
                    this.ownerCt.close();
                  }
                }]

              });

              w.show(null, function(){
                this.loadAggregatee({id:"configuration_panel", container:w.id});
              }, this);

              w.on('close', function(){
                if (w.closeRes == 'OK'){
                  var configurationPanel = this.getChildWidget('configuration_panel');
                  var panels = configurationPanel.getLoadedChildren();
                  var commitData = {};
                  Ext.each(panels, function(p){
                    commitData[p.localId(configurationPanel)] = p.getCommitData();
                  }, this);
                  configurationPanel.commit({commit_data:Ext.encode(commitData)});
                }
              }, this);
            }
          JS
        })
      end
    end

    def initial_aggregatees_with_config_tool
      res = initial_aggregatees_without_config_tool
      
      # Add the accordion as aggregatee, which in its turn aggregates widgets from the configuration_widgets method
      res.merge!(:configuration_panel => {
        :widget_class_name => 'ConfigurationPanel', 
        :items => configuration_widgets,
        :late_aggregation => true
      }) if ext_config[:config_tool]
      
      res
    end

    def tools_with_config_tool
      tools = tools_without_config_tool
      # Add the toolbutton
      tools << 'gear' if ext_config[:config_tool]
      tools
    end
  
  end
end