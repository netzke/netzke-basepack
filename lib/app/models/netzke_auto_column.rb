class NetzkeAutoColumn < ActiveRecord::Base

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
  
    column_types_to_create = {} # columns that must be in the table
    columns_to_expose = []
    
    @@widget.columns.each do |c|
      c.each_pair do |k,v|
        column_hash = {:name => k}
        meta_data = v.is_a?(Hash) && v.delete(:meta)
        if meta_data
          column_hash.merge!(meta_data)
        end
        columns_to_expose.reject!{ |c| c[:name] == k }
        
        columns_to_expose << column_hash 
        
        column_type = case v.class.to_s
        when "TrueClass"
          :boolean
        when "FalseClass"
          :boolean
        when "Fixnum"
          :integer
        else
          :string
        end

        column_types_to_create[k] = {:type => column_type}
      end
    end
  
    # create the table with the fields
    self.connection.create_table('netzke_auto_columns') do |t|
      column_types_to_create.each_pair do |k,v|
        t.column k, v[:type]
      end
    end
  
    # populate the table with data (excluding meta columns attributes)
    NetzkeAutoColumn.create @@widget.columns.map(&:deebeefy_values)
    
    netzke_expose_attributes :id, *columns_to_expose
    
  end

  def self.widget=(widget)
    @@widget = widget
    if Netzke::Base.session["netzke_auto_column_last_widget"] != @@widget.id_name
      rebuild_table
      Netzke::Base.session["netzke_auto_column_last_widget"] = @@widget.id_name
    end
  end
end