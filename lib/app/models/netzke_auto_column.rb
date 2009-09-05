require 'acts_as_list'
class NetzkeAutoColumn < ActiveRecord::Base
  
  acts_as_list
  default_scope :order => "position"

  # Returns an array of column configuration hashes (without the "id" attribute)
  def self.all_columns
    self.all.map do |c|
      column_hash = c.attributes.reject{ |k,v| k == 'id' }
      column_hash.each_pair do |k,v|
        # try to detect JSON format
        begin
          normalized_value = v.is_a?(String) ? ActiveSupport::JSON.decode(v) : v
        rescue ActiveSupport::JSON::ParseError
          normalized_value = v
        end
        column_hash[k] = normalized_value
      end
      column_hash
    end
  end

  # Build the table with columns for this widget
  def self.rebuild_table
    connection.drop_table('netzke_auto_columns') if table_exists?
  
    normalized_config_columns = []
    
    @@widget.class.config_columns.each do |mc|
      column_hash = mc.is_a?(Symbol) ? {:name => mc} : mc
      column_hash[:type] ||= :string
      normalized_config_columns << column_hash
    end
    
    # create the table with the fields
    self.connection.create_table('netzke_auto_columns') do |t|
      normalized_config_columns.each do |mc|
        t.column mc[:name], mc[:type], :default => mc[:default]
      end
      t.column :position, :integer
    end

    # populate the table with data
    NetzkeAutoColumn.create @@widget.normalized_columns.map(&:deebeefy_values)
    
  end

  def self.widget=(widget)
    @@widget = widget
    if Netzke::Base.session["netzke_auto_column_last_widget"] != @@widget.id_name
      rebuild_table
      Netzke::Base.session["netzke_auto_column_last_widget"] = @@widget.id_name
    end
  end
end