module Netzke::ActiveRecord::ComboboxOptions
  module ClassMethods
    # TODO: rename to netzke_options_for (to avoid polluting the namespace)
    # TODO: remove dependency on NetzkePreference, refactor
    def options_for(column, query = "")
      # First, check if we have options for this class and column defined in persistent storage
      NetzkePreference.widget_name = self.name
      options = NetzkePreference[:combobox_options] || {}
      if options[column]
        options[column].select{ |o| o.index(/^#{query}/) }
      elsif respond_to?("#{column}_combobox_options")
        # AR class provides the choices itself
        send("#{column}_combobox_options", query)
      else
        # Returns all unique values for a column, filtered with <tt>query</tt>
        if (assoc_name, *assoc_method = column.split('__')).size > 1
          # column is an association column
          assoc_method = assoc_method.join('__') # in case we get something like country__continent__name
          association = reflect_on_association(assoc_name.to_sym) || raise(NameError, "Association #{assoc_name} not known for class #{name}")
          association.klass.options_for(assoc_method, query)
        else
          column = assoc_name
          if self.column_names.include?(column)
            # it's simply a column in the table
            records = query.empty? ? find_by_sql("select distinct #{column} from #{table_name}") : find_by_sql("select distinct #{column} from #{table_name} where #{column} like '#{query}%'")
            records.map{|r| r.send(column)}
          else
            # it's a "virtual" column - the least effective search
            records = self.find(:all).map{|r| r.send(column)}.uniq
            query.empty? ? records : records.select{|r| r.index(/^#{query}/)}
          end
        end
      end
    end
  end
  
  module InstanceMethods
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end