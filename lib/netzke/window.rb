module Netzke
  # == Window
  # Ext.Window-based widget
  # 
  # == Features
  # * Persistent position
  # * Persistent dimensions
  # 
  # == Instance configuration
  # <tt>:height</tt> and <tt>:width</tt> - besides accepting a number (which would be just standard ExtJS),
  # can accept a string specifying relative sizes, calculated from current browser window dimensions.
  # E.g.: :height => "90%", :width => "60%"
  class Window < Base
    # Based on Ext.Window, naturally
    def self.js_base_class
      "Ext.Window"
    end
    
    # Set the passed item as the only aggregatee
    def initial_aggregatees
      res = {}
      res.merge!(:item => config[:item]) if config[:item]
      res
    end
    
    # Extends the JavaScript class
    def self.js_extend_properties
      {
        :layout => "fit",
        
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            // Width and height may be specified as percentage of available space, e.g. "60%".
            // Convert them into actual pixels.
            Ext.each(["width", "length"], function(k){
              if (Ext.isString(this[k])) {
                this[k] = Ext.lib.Dom.getViewHeight() * parseFloat("." + this[k].substr(0, this[k].length - 1)); // "66%" => ".66"
              }
            });
            
            // Superclass' initComponent
            #{js_full_class_name}.superclass.initComponent.call(this);
            
            // Set the move and resize events after window is shown, so that they don't fire at initial rendering
            this.on("show", function(){
              this.on("move", this.onMoveResize, this);
              this.on("resize", this.onMoveResize, this);
            }, this);

            if (this.itemConfig){
              this.instantiateChild(this.itemConfig);
            }
          }
        END_OF_JAVASCRIPT
      
        :on_move_resize => <<-END_OF_JAVASCRIPT.l,
          function(){
            var x = this.getPosition()[0], y = this.getPosition()[1], w = this.getSize().width, h = this.getSize().height;

            // Don't bother the server twice when both move and resize events are called at the same time
            // (happens when the left or upper window border is dragged)
            if (this.moveResizeTimer) {clearTimeout(this.moveResizeTimer)};
            
            this.moveResizeTimer = (function(sizeAndPosition){
              this.setSizeAndPosition(sizeAndPosition); // API call
            }).defer(10, this, [{x:x, y:y, w:w, h:h}]); // 10ms should be enough
          }
        END_OF_JAVASCRIPT
        
      }
    end
    
    # Processing API calls from client
    api :set_size_and_position
    def set_size_and_position(params)
      update_persistent_ext_config(
        :x => params[:x].to_i, 
        :y => params[:y].to_i, 
        :width => params[:w].to_i, 
        :height => params[:h].to_i
      )
      {}
    end
  end
end