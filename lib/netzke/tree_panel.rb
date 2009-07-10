class Netzke::TreePanel < Netzke::Base
  api :get_children
  
  def self.js_base_class
    "Ext.tree.TreePanel"
  end
  
  def self.js_default_config
    super.merge({
      :root => {:text => '/', :id => 'source'},
      :loader => {:data_url => "config.api.getChildren".l}
    })
  end
  
  def self.js_extend_properties
    {
      :on_widget_load => <<-JS.l,
        function(){
        }
      JS
      :refresh_handler => <<-JS.l,
        function(){
          console.info('refresh!');
        }
      JS
      :add_handler => <<-JS.l,
        function(e){
          console.info(e);
        }
      JS
      :edit_handler => <<-JS.l,
        function(e){
          console.info(e);
        
        }
      JS
      :delete_handler => <<-JS.l
        function(e){
          console.info(e);
        
        }
      JS
    }
  end
  
  def actions
    { :add    => {:text => 'Add'},
      :edit   => {:text => 'Edit'},
      :delete => {:text => 'Delete', :disabled => true}
    }
  end
  
  def bbar
    persistent_config[:bbar] ||= config[:bbar] == false ? nil : config[:bbar] || %w{ add edit delete }
  end
  
  def tools
    persistent_config[:tools] ||= config[:tools] == false ? nil : config[:tools] #|| %w{ gear refresh }
  end
  
  def tbar
    persistent_config[:tbar] ||= config[:tbar] == false ? nil : config[:tbar]
  end

  def menu
    persistent_config[:menu] ||= config[:menu] == false ? nil : config[:menu] # || [{:text => 'Button', :menu => ['edit', {:text => 'Submenu', :menu => ['delete']}]}]
  end
  
  def get_children(params)
    klass = config[:data_class_name].constantize
    node = params[:node] == 'source' ? klass.find_by_parent_id(nil) : klass.find(params[:node].to_i)
    node.children.map{|n| {:text => n.name, :id => n.id}}
  end
end