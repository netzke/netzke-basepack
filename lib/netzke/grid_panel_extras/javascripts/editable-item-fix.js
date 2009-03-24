/* Fixing Ext's EditableItem render problem */
Ext.menu.EditableItem.prototype.onRender = function(container){
    var s = container.createChild({
    	cls: this.itemCls,
    	html: '<img src="' + this.icon + '" class="x-menu-item-icon" style="margin: 3px 3px 2px 2px; position: relative;" />'
    });
    
    Ext.apply(this.config, {width: 125});
    this.editor.render(s);
    
    this.el = s;
    this.relayEvents(this.editor.el, ["keyup"]);
    
    if(Ext.isGecko) {
			s.setStyle('overflow', 'auto');
    }
	
    Ext.menu.EditableItem.superclass.onRender.call(this, container);
}