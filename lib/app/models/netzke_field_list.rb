# TODO: clean up, document and test
class NetzkeFieldList < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :parent, :class_name => "NetzkeFieldList"
  has_many :children, :class_name => "NetzkeFieldList", :foreign_key => "parent_id"


  def self.update_fields(owner_id, attrs_hash)
    self.find_all_below_current_authority_level(owner_id).each do |list|
      list.update_attrs(attrs_hash)
    end
  end

  # Updates attributes in the list
  def update_attrs(attrs_hash)
    list = ActiveSupport::JSON.decode(self.value)
    list.each do |field|
      field.merge!(attrs_hash[field["name"]]) if attrs_hash[field["name"]]
    end
    update_attribute(:value, list.to_json)
  end
  
  def append_attr(attr_hash)
    list = ActiveSupport::JSON.decode(self.value)
    list << attr_hash
    update_attribute(:value, list.to_json)
  end

  def self.find_all_below_current_authority_level(pref_name)
    authority_level, authority_id = Netzke::Base.authority_level
    case authority_level
    when :world
      self.all(:conditions => {:name => pref_name})
    when :role
      role = Role.find(authority_id)
      role.users.inject([]) do |r, user|
        r += self.all(:conditions => {:user_id => user.id, :name => pref_name})
      end
    else
      []
    end
  end
  
  def self.find_all_lists_under_current_authority(model_name)
    authority_level, authority_id = Netzke::Base.authority_level
    case authority_level
    when :world
      self.all(:conditions => {:model_name => model_name})
    when :role
      role = Role.find(authority_id)
      role.users.inject([]) do |r, user|
        r += self.all(:conditions => {:user_id => user.id, :model_name => model_name})
      end
    when :user
      self.all(:conditions => {:user_id => authority_id, :model_name => model_name})
    when :self
      self.all(:conditions => {:user_id => authority_id, :model_name => model_name})
    else
      []
    end
    
  end
  
  
  # Replaces the list with the data - only for the list found for the current authority. 
  # If the list is not found, it's created.
  def self.update_list_for_current_authority(pref_name, data, model_name = nil)
    pref = find_or_create_pref_to_read(pref_name)
    pref.value = data.to_json
    pref.model_name = model_name
    pref.save!
  end
  

  # If the <tt>model</tt> param is provided, then this preference will be assigned a parent preference
  # that configures the attributes for that model. This way we can track all preferences related to a model.
  def self.write_list(name, list, model = nil)
    pref_to_store_the_list = self.pref_to_write(name)
    pref_to_store_the_list.try(:update_attribute, :value, list.to_json)
    
    # link this preference to the parent that contains default attributes for the same model
    if model
      model_level_attrs_pref = self.pref_to_read("#{model.tableize}_model_attrs")
      model_level_attrs_pref.children << pref_to_store_the_list if model_level_attrs_pref && pref_to_store_the_list
    end
  end
  
  def self.read_list(name)
    json_encoded_value = self.pref_to_read(name).try(:value)
    ActiveSupport::JSON.decode(json_encoded_value).map(&:symbolize_keys) if json_encoded_value
  end

  # Read model-level attrs
  # def self.read_attrs_for_model(model_name)
  #   read_list(model_name)
  #   # read_list("#{model.tableize}_model_attrs")
  # end
  
  # Write model-level attrs
  # def self.write_attrs_for_model(model_name, data)
  #   # write_list("#{model_name.tableize}_model_attrs", data)
  #   write_list(model_name, data)
  # end
  
  # Options:
  # :attr - attribute to propagate. If not specified, all attrs found in configuration for the model
  # will be propagated.
  def self.update_children_on_attr(model, options = {})
    attr_name = options[:attr].try(:to_s)
    
    parent_pref = pref_to_read("#{model.tableize}_model_attrs")
    
    if parent_pref
      parent_list = ActiveSupport::JSON.decode(parent_pref.value)
      parent_pref.children.each do |ch|
        child_list = ActiveSupport::JSON.decode(ch.value)
        
        if attr_name
          # propagate a certain attribute
          propagate_attr(attr_name, parent_list, child_list)
        else
          # propagate all attributes found in parent
          all_attrs = parent_list.first.try(:keys)
          all_attrs && all_attrs.each{ |attr_name| propagate_attr(attr_name, parent_list, child_list) }
        end
        
        ch.update_attribute(:value, child_list.to_json)
      end
    end
  end
  
  # meta_attrs:
  #   {"city"=>{"included"=>true}, "building_number"=>{"default_value"=>100}}
  def self.update_children(model, meta_attrs)
    parent_pref = pref_to_read("#{model.tableize}_model_attrs")


    if parent_pref
      parent_pref.children.each do |ch|
        child_list = ActiveSupport::JSON.decode(ch.value)
        
        meta_attrs.each_pair do |k,v|
          child_list.detect{ |child_attr| child_attr["name"] == k }.try(:merge!, v)
        end
        
        ch.update_attribute(:value, child_list.to_json)
      end
    end
  end

  private
  
    def self.propagate_attr(attr_name, src_list, dest_list)
      for src_field in src_list
        dest_field = dest_list.detect{ |df| df["name"] == src_field["name"] }
        dest_field[attr_name] = src_field[attr_name] if dest_field && src_field[attr_name]
      end
    end
  
    # Overwrite pref_to_read, pref_to_write methods, and find_all_for_widget if you want a different way of 
    # identifying the proper preference based on your own authorization strategy.
    #
    # The default strategy is:
    #   1) if no masq_user or masq_role defined
    #     pref_to_read will search for the preference for user first, then for user's role
    #     pref_to_write will always find or create a preference for the current user (never for its role)
    #   2) if masq_user or masq_role is defined
    #     pref_to_read and pref_to_write will always take the masquerade into account, e.g. reads/writes will go to
    #     the user/role specified
    #   
    def self.pref_to_read(name)
      name = name.to_s
      session = Netzke::Base.session
      cond = {:name => name}
    
      if session[:masq_user]
        # first, get the prefs for this user it they exist
        res = self.find(:first, :conditions => cond.merge({:user_id => session[:masq_user]}))
        # if it doesn't exist, get them for the user's role
        user = User.find(session[:masq_user])
        res ||= self.find(:first, :conditions => cond.merge({:role_id => user.role.id}))
        # if it doesn't exist either, get them for the World (role_id = 0)
        res ||= self.find(:first, :conditions => cond.merge({:role_id => 0}))
      elsif session[:masq_role]
        # first, get the prefs for this role
        res = self.find(:first, :conditions => cond.merge({:role_id => session[:masq_role]}))
        # if it doesn't exist, get them for the World (role_id = 0)
        res ||= self.find(:first, :conditions => cond.merge({:role_id => 0}))
      elsif session[:masq_world]
        res = self.find(:first, :conditions => cond.merge({:role_id => 0}))
      elsif session[:netzke_user_id]
        user = User.find(session[:netzke_user_id])
        # first, get the prefs for this user
        res = self.find(:first, :conditions => cond.merge({:user_id => user.id}))
        # if it doesn't exist, get them for the user's role
        res ||= self.find(:first, :conditions => cond.merge({:role_id => user.role.id}))
        # if it doesn't exist either, get them for the World (role_id = 0)
        res ||= self.find(:first, :conditions => cond.merge({:role_id => 0}))
      else
        res = self.find(:first, :conditions => cond)
      end
    
      res      
    end
    
    def self.find_or_create_pref_to_read(name)
      name = name.to_s
      attrs = {:name => name}
      extend_attrs_for_current_authority(attrs)
      self.first(:conditions => attrs) || self.new(attrs)
    end
    
    def self.extend_attrs_for_current_authority(hsh)
      authority_level, authority_id = Netzke::Base.authority_level
      case authority_level
      when :world
        hsh.merge!(:role_id => 0)
      when :role
        hsh.merge!(:role_id => authority_id)
      when :user
        hsh.merge!(:user_id => authority_id)
      when :self
        hsh.merge!(:user_id => authority_id)
      end
    end
  
    def self.pref_to_write(name)
      name = name.to_s
      session = Netzke::Base.session
      cond = {:name => name}
    
      if session[:masq_user]
        cond.merge!({:user_id => session[:masq_user]})
        # first, try to find the preference for masq_user
        res = self.find(:first, :conditions => cond)
        # if it doesn't exist, create it
        res ||= self.new(cond)
      elsif session[:masq_role]
        # first, delete all the corresponding preferences for the users that have this role
        Role.find(session[:masq_role]).users.each do |u|
          self.delete_all(cond.merge({:user_id => u.id}))
        end
        cond.merge!({:role_id => session[:masq_role]})
        res = self.find(:first, :conditions => cond)
        res ||= self.new(cond)
      elsif session[:masq_world]
        # first, delete all the corresponding preferences for all users and roles
        self.delete_all(cond)
        # then, create the new preference for the World (role_id = 0)
        res = self.new(cond.merge(:role_id => 0))
      elsif session[:netzke_user_id]
        res = self.find(:first, :conditions => cond.merge({:user_id => session[:netzke_user_id]}))
        res ||= self.new(cond.merge({:user_id => session[:netzke_user_id]}))
      else
        res = self.find(:first, :conditions => cond)
        res ||= self.new(cond)
      end
      res
    end
end
