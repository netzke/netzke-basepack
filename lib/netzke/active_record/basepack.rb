require "activerecord"

module Netzke::ActiveRecord
  # Provides extensions to all ActiveRecord-based classes
  module Basepack
    def self.included(base)
      base.extend ClassMethods
    end
    
    # Allow nested association access (assocs separated by "." or "__"), e.g.: proxy_service.asset__gui_folder__name
    # Example:
    # 
    #   Book.first.genre__name = 'Fantasy'
    # 
    # is the same as:
    # 
    #   Book.first.genre = Genre.find_by_name('Fantasy')
    #
    # The result - easier forms and grids that handle nested models: simply specify column/field name as "genre__name".
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
    
    # Make respond_to? return true for association assignment method, like "genre__name="
    def respond_to?(method, include_private = false)
      split = method.to_s.split(/__/)
      if split.size > 1
        if split.last =~ /=$/ 
          if split.size == 2
            # search for association and assign it to self
            assoc = self.class.reflect_on_association(split.first.to_sym)
            assoc_method = split.last.chop
            if assoc
              assoc.klass.respond_to?("find_by_#{assoc_method}")
            else
              super
            end
          else
            super
          end
        else
          # self.respond_to?(split.first) ? self.send(split.first).respond_to?(split[1..-1].join("__")) : false
          super
        end
      else
        super
      end
    end

    module ClassMethods

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
      
  end
end

# Extend ActiveRecord
ActiveRecord::Base.class_eval do
  include Netzke::ActiveRecord::Basepack
end
