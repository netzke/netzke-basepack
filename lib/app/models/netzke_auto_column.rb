class NetzkeAutoColumn < ActiveRecord::Base

  # Returns an array of column configuration hashes (without the "id" attribute)
  def self.all_columns
    self.all.map{ |c| c.attributes.reject{ |k,v| k == 'id' } }
  end

  # Build the table with columns for this widget
  def self.rebuild_table
    connection.drop_table('netzke_auto_columns') if table_exists?
  
    # which columns must be in the table?
    columns_to_create = {}
    @@widget.columns.each do |c|
      c.each_pair do |k,v|
        if columns_to_create[k].nil? # column isn't yet added
          column_type = case v.class.to_s
            when "TrueClass"
              :boolean
            when "FalseClass"
              :boolean
            when "String"
              :string
            when "Fixnum"
              :integer
            else
              :string
            end
          columns_to_create[k] = {:type => column_type}
        end
      end
    end
  
    # create the table with the fields
    self.connection.create_table('netzke_auto_columns') do |t|
      columns_to_create.each_pair do |k,v|
        t.column k, v[:type]
      end
    end
  
    # populate the table with data
    NetzkeAutoColumn.create @@widget.columns.map{ |c| c.stringify_values! }
  end

  def self.widget=(widget)
    @@widget = widget
    if Netzke::Base.session["netzke_auto_column_last_widget"] != @@widget.id_name
      rebuild_table
      Netzke::Base.session["netzke_auto_column_last_widget"] = @@widget.id_name
    end
  end
end