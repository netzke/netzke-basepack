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
      {:item => config[:item]}
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
              this.on("move", this.onMove, this);
              this.on("resize", this.onSelfResize, this, {buffer: 50}); // Work around firing "resize" event twice (currently a bug in ExtJS)
            }, this);
            this.instantiateChild(this.itemConfig);
          }
        END_OF_JAVASCRIPT
      
        :on_move => <<-END_OF_JAVASCRIPT.l,
          function(w,x,y){
            this.moveToPosition({x:x, y:y});
          }
        END_OF_JAVASCRIPT

        :on_self_resize => <<-END_OF_JAVASCRIPT.l,
          function(w, width, height){
            this.selfResize({w:width, h:height});
          }
        END_OF_JAVASCRIPT
      }
    end
    
    # Processing API calls from client
    api :move_to_position
    def move_to_position(params)
      update_persistent_ext_config(:x => params[:x].to_i, :y => params[:y].to_i)
      {}
    end
    
    api :self_resize
    def self_resize(params)
      update_persistent_ext_config(:width => params[:w].to_i, :height => params[:h].to_i)
      {}
    end
  end
end