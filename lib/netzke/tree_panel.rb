class Netzke::TreePanel < Netzke::Widget::Base
  api :get_children
  
  def self.js_base_class
    "Ext.tree.TreePanel"
  end
  
  def self.js_properties
    {
      :root => {:text => '/', :id => 'source'}
    }
  end
  
  def js_config
    super.deep_merge({
      :loader => {:data_url => global_id+"__get_children".l}
    })
  end
  
  def get_children(params)
    klass = config[:model].constantize
    node = params[:node] == 'source' ? klass.find_by_parent_id(nil) : klass.find(params[:node].to_i)
    node.children.map{|n| {:text => n.name, :id => n.id, :leaf => n.children.empty?}}
  end
end