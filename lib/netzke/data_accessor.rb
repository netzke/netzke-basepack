require 'netzke/active_record'

module Netzke
  # This module is included into such data-driven components as GridPanel, FormPanel, etc.
  module DataAccessor
    
    # Returns options for comboboxes in grids/forms
    def combobox_options_for_column(column, method_options = {})
      query = method_options[:query]
      
      # First, check if we have options for this column defined in persistent storage
      options = column[:combobox_options] && column[:combobox_options].split("\n")
      if options
        query ? options.select{ |o| o.index(/^#{query}/) }.map{ |el| [el] } : options
      else      
        assoc, assoc_method = assoc_and_assoc_method_for_column(column)
      
        if assoc
          # Options for an asssociation attribute
          
          relation = assoc.klass.where({})
          
          relation = relation.extend_with(method_options[:scope]) if method_options[:scope]
        
          if assoc.klass.column_names.include?(assoc_method)
            # apply query
            relation = relation.where(:"#{assoc_method}".like => "#{query}%") if query.present?
            relation.all.map{ |r| [r.send(assoc_method)] }
          else
            relation.all.map{ |r| r.send(assoc_method) }.select{ |value| value =~ /^#{query}/  }.map{ |v| [v] }
          end
        
        else
          # Options for a non-association attribute
          res=data_class.netzke_combo_options_for(column[:name], method_options)
					
					# ensure it is an array-in-array, as Ext will fail otherwise
					raise RuntimeError, "netzke_combo_options_for should return an Array" unless res.kind_of? Array
					return [[]] if res.empty?
					return [res] unless res.first.kind_of? Array
					return res
					
					
        end
      end
    end
    
    # Normalize array of attributes
    # [:col1, "col2", {:name => :col3}] =>
    #   [{:name => "col1"}, {:name => "col2"}, {:name => "col3"}]
    def normalize_attrs(attrs)
      attrs.map{ |a| normalize_attr(a) }
    end
    
    # Normalize an attribute, e.g.:
    # :first_name => 
    #   {:name => "first_name"}
    def normalize_attr(a)
      a.is_a?(Symbol) || a.is_a?(String) ? {:name => a.to_s} : a.merge(:name => a[:name].to_s)
    end
    
    # Returns association and association method for a column
    def assoc_and_assoc_method_for_column(c)
      assoc_name, assoc_method = c[:name].split('__')
      assoc = data_class.reflect_on_association(assoc_name.to_sym) if assoc_method
      [assoc, assoc_method]
    end
   
    def association_attr?(name)
      !!name.to_s.index("__")
    end
    
  end
end