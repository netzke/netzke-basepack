module Netzke
  module ActiveRecordExtensions
    def self.included(base)
      base.extend ActiveRecordClassMethods
    end
    
    module ActiveRecordClassMethods
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