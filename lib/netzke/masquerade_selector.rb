module Netzke
  class MasqueradeSelector < TabPanel
    
    def items
      @items ||= [{
          :name              => "roles",
          :active            => true,
          :class_name => "GridPanel",
          :model   => 'Role',
          :columns           => [:id, :name],
          :ext_config => {
            :header        => false,
            :bbar => ['search']
          }
        },{
          :name                 => "users",
          :preloaded            => true,
          :class_name    => "GridPanel", 
          :model      => 'User', 
          :ext_config           => {
            :header        => false,
            :rows_per_page => 10,
            :bbar => ['search']
          },
          :columns => [:id, :login]
      }]
    end

    def self.js_extend_properties
      {
        :after_constructor => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.items.each(function(tab){
              tab.on('add', function(ct, cmp){
                cmp.on('rowclick', this.rowclickHandler, this);
              }, this);
            }, this);
          }
        END_OF_JAVASCRIPT
        
        :rowclick_handler => <<-END_OF_JAVASCRIPT.l
          function(grid, rowIndex, e){
            var mode = grid.id.split("__").pop();
            var normMode = mode === 'users' ? 'user' : 'role';
            this.masquerade = {};
            this.masquerade[normMode] = grid.store.getAt(rowIndex).get('id');
          }
        END_OF_JAVASCRIPT
      }
    end
    
  end
end