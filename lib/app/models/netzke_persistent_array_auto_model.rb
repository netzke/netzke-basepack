require 'acts_as_list'
class NetzkePersistentArrayAutoModel < ActiveRecord::Base
  set_table_name "netzke_temp_table"
  connection.create_table(table_name) if !connection.table_exists?(table_name)  

  acts_as_list
  default_scope :order => "position"

  cattr_accessor :config
  
  def self.all_columns
    self.all.map{ |c| c.attributes.reject{ |k,v| k == 'id' || k == 'position' } }
  end
  
  # Configuration
  def self.configure(config)
    self.config = config
    if NetzkePreference.first(:conditions => {:name => "netzke_persistent_array_refresh_token"}).try(:value) != refresh_token || !connection.table_exists?(table_name)
      rebuild_table(:columns => config[:columns], :initial_data => config[:initial_data])
    end
    NetzkePreference.find_or_create_by_name("netzke_persistent_array_refresh_token").update_attribute(:value, refresh_token)
  end
  
  def self.rebuild_table(config)
    connection.drop_table(table_name) if connection.table_exists?(table_name)
    # create the table with the fields
    self.connection.create_table(table_name) do |t|
      config[:columns].each do |c|
        c = c.dup # to make next line shorter
        t.column c.delete(:name), c.delete(:type), c
      end
    end

    self.reset_column_information

    # self.create config[:initial_data]
    self.replace_data(config[:initial_data])
  end
  
  def self.replace_data(data)
    # only select those attributes that were provided to us as columns. The rest is ignored.
    column_names = config[:columns].map{ |c| c[:name] }
    clean_data = data.collect{ |c| c.reject{ |k,v| !column_names.include?(k.to_s) } } 
    
    self.delete_all
    self.create(clean_data)
  end
  
  private
  
    def self.refresh_token
      @@refresh_token ||= begin
        session = Netzke::Base.session
        config[:owner] + (session[:masq_user] || session[:masq_role] || session[:masq_world] || session[:netzke_user_id]).to_s
      end
    end
  
end