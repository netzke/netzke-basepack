class NetzkeFieldList < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  
  def self.write_list(name, list)
    self.pref_to_write(name).try(:update_attribute, :value, list.to_json)
  end
  
  def self.read_list(name)
    json_encoded_value = self.pref_to_read(name).try(:value)
    ActiveSupport::JSON.decode(json_encoded_value) if json_encoded_value
  end

  private
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
