module Netzke::Plugins
  # Include this module into any widget where you want a "gear" tool button in the top toolbar 
  # which will triggger a modal window, which will load the ConfigurationPanel TabPanel-based 
  # widget, which in its turn will contain all the aggregatees specified in widget's "configuration_widgets" 
  # method (which *must* be defined)
  module ConfigurationTool
    def self.included(base)
      base.extend ClassMethods
      
      base.class_eval do
        # replacing instance methods
        [:config, :initial_aggregatees, :js_config].each{ |m| alias_method_chain m, :config_tool }
        
        # replacing class methods
        class << self
          alias_method_chain :js_extend_properties, :config_tool
        end

        # API to commit the changes
        api :commit
      end

      # if you include ConfigurationTool, you are supposed to provide configuration_widgets method which will returns an array of arrgeratees
      # that will be included in the property window (each in its own tab or accordion pane)
      raise "configuration_widgets method undefined" unless base.instance_methods.include?("configuration_widgets")
    end

    module ClassMethods
      def js_extend_properties_with_config_tool
        js_extend_properties_without_config_tool.merge({
          :gear => <<-END_OF_JAVASCRIPT.l
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
                  disabled: !this.configurable,
                  tooltip: this.configurable ? null : "No dynamic configuration for this component",
                  handler:function(){
                    w.closeRes = 'OK'; 
                    w.close();
                  }
                },{
                  text:'Cancel',
                  handler:function(){
                    w.closeRes = 'cancel'; 
                    w.close();
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
                    if (p.getCommitData) {commitData[p.localId(configurationPanel)] = p.getCommitData();}
                  }, this);
                  configurationPanel.commit({commit_data:Ext.encode(commitData)});
                }
              }, this);
            }
          END_OF_JAVASCRIPT
        })
      end
    end

    def config_with_config_tool
      orig_config = config_without_config_tool
      return orig_config unless config_tool_needed?
      orig_config.deep_merge({
        :ext_config => {
          :tools => orig_config[:ext_config][:tools].clone << "gear",
          :header => true
        }
      })
    end

    def initial_aggregatees_with_config_tool
      res = initial_aggregatees_without_config_tool
      
      # Add the ConfigurationPanel as aggregatee, which in its turn aggregates widgets from the 
      # configuration_widgets method
      res.merge!(:configuration_panel => {
        :widget_class_name => 'ConfigurationPanel', 
        :items => configuration_widgets,
        :late_aggregation => true
      }) if config_tool_needed?
      
      res
    end

    def tools_with_config_tool
      tools = tools_without_config_tool
      # Add the toolbutton
      tools << 'gear' if config_tool_needed?
      tools
    end
  
    def js_config_with_config_tool
      orig_config = js_config_without_config_tool
      orig_config.merge(:configurable => config[:persistent_config])
    end
  
    def config_tool_needed?
      config_without_config_tool[:ext_config][:config_tool] || config_without_config_tool[:ext_config][:mode] == :config
    end
  
  end
end