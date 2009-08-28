module Netzke
  module BasepackActiveRecord
    def self.included(base)
      base.extend ActiveRecordClassMethods
    end

    # Allow nested association access (assocs separated by "." or "__"), e.g.: proxy_service.asset__gui_folder__name
    # Example:
    # b = Book.first
    # b.genre__name = 'Fantasy' => b.genre = Genre.find_by_name('Fantasy')
    # NOT IMPLEMENTED (any real use?): b.genre__catalog__name = 'Best sellers' => b.genre_id = b.genre.find_by_catalog_id(Catalog.find_by_name('Best sellers')).id
    def method_missing(method, *args, &block)
      # if refering to a column, just pass it to the original method_missing
      return super if self.class.column_names.include?(method.to_s)
      
      split = method.to_s.split(/\.|__/)
      if split.size > 1
        if split.last =~ /=$/ 
          if split.size == 2
            # search for association and assign it to self
            assoc = self.class.reflect_on_association(split.first.to_sym)
            assoc_method = split.last.chop
            if assoc
              begin
                assoc_instance = assoc.klass.send("find_by_#{assoc_method}", *args)
              rescue NoMethodError
                assoc_instance = nil
                logger.debug "!!! no find_by_#{assoc_method} method for class #{assoc.klass.name}\n"
              end
              if (assoc_instance)
                self.send("#{split.first}=", assoc_instance)
              else
                logger.debug "!!! Couldn't find association #{split.first} by #{assoc_method} '#{args.first}'"
              end
            else
              super
            end
          else
            super
          end
        else
          res = self
          split.each do |m|
            if res.respond_to?(m)
              res = res.send(m) unless res.nil?
            else
              res.nil? ? nil : super
            end
          end
          res
        end
      else
        super
      end
    end
    
    # Transforms a record to array of values according to the passed columns. Works both for grids and forms.
    # TODO: should be moved out to form/grid specific code
    def to_array(columns)
      res = []
      for c in columns
        nc = c.is_a?(Symbol) ? {:name => c} : c
        res << send(nc[:name]) unless nc[:excluded]
      end
      res
    end
    
    module ActiveRecordClassMethods
      # next and previous to id records
      # def next(id)
      #   find(:first, :conditions => ["#{primary_key} > ?", id])
      # end
      # def previous(id)
      #   find(:first, :conditions => ["#{primary_key} < ?", id], :order => "#{primary_key} DESC")
      # end
      
      # Returns all unique values for a column, filtered by the query
      def options_for(column, query = nil)
        if respond_to?("#{column}_combobox_options")
          # AR class provides the choices itself
          send("#{column}_combobox_options", query)
        else
          if (assoc_name, *assoc_method = column.split('__')).size > 1
            # column is an association column
            assoc_method = assoc_method.join('__') # in case we get something like country__continent__name
            association = reflect_on_association(assoc_name.to_sym) || raise(NameError, "Association #{assoc_name} not known for class #{name}")
            association.klass.options_for(assoc_method, query)
          else
            column = assoc_name
            if self.column_names.include?(column)
              # it's just a column
              records = query.nil? ? find_by_sql("select distinct #{column} from #{table_name}") : find_by_sql("select distinct #{column} from #{table_name} where #{column} like '#{query}%'")
              records.map{|r| r.send(column)}
            else
              # it's a "virtual" column - the least effective search
              records = self.find(:all).map{|r| r.send(column)}.uniq
              query.nil? ? records : records.select{|r| r.index(/^#{query}/)}
            end
          end
        end
      end
      
      # which columns are to be picked up by grids and forms
      def netzke_expose_attributes(*args)
        if args.first == :all
          column_names = self.column_names.map(&:to_sym) + netzke_virtual_attributes
          if args.last.is_a?(Hash) && columns_to_exclude = args.last[:except]
            column_names.reject!{ |n| [*columns_to_exclude].include?(n) }
          end
          write_inheritable_attribute(:exposed_attributes, column_names)
        else
          write_inheritable_attribute(:exposed_attributes, args)
        end
      end
      
      def netzke_exposed_attributes
        read_inheritable_attribute(:exposed_attributes) || write_inheritable_attribute(:exposed_attributes, netzke_expose_attributes(:all))
      end
      
      # virtual "columns" that simply correspond to instance methods of an ActiveRecord class
      def netzke_virtual_attribute(name, config = {})
        config = {:name => name}.merge(config)
        write_inheritable_attribute(:virtual_attributes, (read_inheritable_attribute(:virtual_attributes) || []) << config)
      end

      # def netzke_virtual_attribute(name)
      #   write_inheritable_attribute(:virtual_attributes, (read_inheritable_attribute(:virtual_attributes) || []) << name)
      # end
      
      def netzke_virtual_attributes
        read_inheritable_attribute(:virtual_attributes) || []
      end
      
      def is_netzke_virtual_attribute?(column)
        read_inheritable_attribute(:virtual_attributes).keys.include?(column)
      end
      
      # all columns + virtual attributes
      def all_netzke_attribute_names
        column_names + netzke_virtual_attributes.map(&:to_s)
      end
      
    end
  end
end

# ActiveRecord::Base.class_eval do
#   include Netzke::BasepackActiveRecord
# end
