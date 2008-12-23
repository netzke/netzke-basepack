module Netzke
  module ActiveRecordExtensions
    def self.included(base)
      base.extend ActiveRecordClassMethods
    end

    #
    # Allow nested association acces (assocs separated by "." or "__"), e.g.: proxy_service.send('asset__gui_folder__name')
    # Example:
    # b = Book.first
    # b.genre__name = 'Fantasy' => b.genre = Genre.find_by_name('Fantasy')
    # NOT IMPLEMENTED: ANY USE? b.genre__catalog__name = 'Best sellers' => b.genre_id = b.genre.find_by_catalog_id(Catalog.find_by_name('Best sellers')).id
    #
    
    def method_missing(method, *args, &block)
      # if refering to a column, just pass it to the originar method_missing
      return super if self.class.column_names.include?(method.to_s)
      
      split = method.to_s.split(/\.|__/)
      if split.size > 1
        if split.last =~ /=$/ 
          if split.size == 2
            # search for association and assign it to self
            assoc = self.class.reflect_on_association(split.first.to_sym)
            assoc_method = split.last.chop
            if assoc
              assoc_instance = assoc.klass.send("find_by_#{assoc_method}", *args)
              raise ArgumentError, "Couldn't find association #{split.first} by #{assoc_method} '#{args.first}'" unless assoc_instance
              self.send("#{split.first}=", assoc_instance)
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
    
    
    module ActiveRecordClassMethods
      def choices_for(column, query = nil)
        if respond_to?("#{column}_choices", query)
          # AR class provides the choices itself
          send("#{column}_choices")
        else
          if (assoc_name, *assoc_method = column.split('__')).size > 1
            # column is an association column
            assoc_method = assoc_method.join('__') # in case we get something like country__continent__name
            association = reflect_on_association(assoc_name.to_sym) || raise(NameError, "Association #{assoc_name} not known for class #{name}")
            association.klass.choices_for(assoc_method, query)
          else
            column = assoc_name
            if self.column_names.include?(column)
              # it's just a column
              records = query.nil? ? find_by_sql("select distinct #{column} from #{table_name}") : find_by_sql("select distinct #{column} from #{table_name} where #{column} like '#{query}%'")
              records.map{|r| r.send(column)}
            else
              # it's a "virtual" column - the least effective search
              records = self.find(:all).map{|r| r.send(column)}.uniq
              query.nil? ? records : records.select{|r| r.send(column).index(/^#{query}/)}
            end
          end
        end
      end
      
      # which columns are to be picked up by grids and forms
      def expose_columns(columns, *args)
        if columns == :all
          write_inheritable_attribute(:exposed_columns, self.column_names.map(&:to_sym))
        else
          write_inheritable_attribute(:exposed_columns, columns)
        end
      end
      
      def exposed_columns
        read_inheritable_attribute(:exposed_columns) || write_inheritable_attribute(:exposed_columns, expose_columns(:all) + virtual_columns)
      end
      
      # virtual "columns" that simply correspond to instance methods of an ActiveRecord class
      def virtual_column(config)
        if config.is_a?(Symbol) 
          config = {:name => config}
        else
          config = {:name => config.keys.first}.merge(config.values.first)
        end
        write_inheritable_attribute(:virtual_columns, (read_inheritable_attribute(:virtual_columns) || []) << config)
      end
      
      def virtual_columns
        read_inheritable_attribute(:virtual_columns) || []
      end
      
      def is_virtual_column?(column)
        read_inheritable_attribute(:virtual_columns).keys.include?(column)
      end
      
      #
      # Used by Netzke::Grid
      #
      
      DEFAULT_COLUMN_WIDTH = 100
      
      def default_column_config(config)
        config = {:name => config} if config.is_a?(Symbol) # optionally we may get only a column name (as Symbol)
        type = (columns_hash[config[:name].to_s] && columns_hash[config[:name].to_s].type) || :virtual

        # general config
        res = {
          :name => config[:name].to_s || "unnamed",
          :label => config[:label] || config[:name].to_s.humanize,
          :read_only => config[:name] == :id, # make "id" column read-only by default
          :hidden => config[:name] == :id, # hide "id" column by default
          :width => DEFAULT_COLUMN_WIDTH,
          :shows_as => :text_field
        }

        case type
          when :integer
            res[:shows_as] = :number_field
          when :boolean
            res[:shows_as] = :checkbox
            res[:width] = 50
          when :date
            res[:shows_as] = :date_field
          when :datetime
            res[:shows_as] = :datetime
          when :string
            res[:shows_as] = :text_field
        end

        res.merge(config) # merge with custom confg (it has the priority)
      end
      
      #
      # Used by Netzke::Form
      #
      
      DEFAULT_FIELD_WIDTH = 100
      DEFAULT_FIELD_HEIGHT = 50
      def default_field_config(config)
        # TODO
      end
      
    end
  end
end

ActiveRecord::Base.class_eval do
  include Netzke::ActiveRecordExtensions
end
