module Netzke
  # Abstract GridPanel-based editor for a JSON array of homogenious objects.
  # Inherit from it in order to override:
  #   <tt>store_data</p> - passes the data to be saved (e.g. to the persistant storage)
  #   <tt>initial_data</p> - should return initial data (e.g. from the persistant storage)
  # For an example of an implementation, see Netzke::FieldsConfigurator.
  class JsonArrayEditor < GridPanel
    def initialize(*args)
      super
      data_class.configure(:owner => global_id, :columns => dynamic_fields, :initial_data => initial_data)
    end
    
    def data_class
      NetzkePersistentArrayAutoModel
    end

    # Fields for NetzkePersistentArrayAutoModel (override it)
    def dynamic_fields
      default_columns.collect do |c| 
        {
          :name => c[:name], 
          :type => c[:attr_type] == :json ? :text : c[:attr_type], # store :json columns as :text
          :default => c[:default_value]
        } 
      end
    end

    # Default predifined columns (override if needed)
    def default_columns
      [{
        :name => :id,
        :attr_type => :integer
      },{
        :name => :name,
        :attr_type => :string
      },{
        :name => :position,
        :attr_type => :integer
      }]
    end
    
    # Don't show the config tool
    # def config_tool_needed?
    #   false
    # end
    
    def before_load
      data_class.rebuild_table
      super
    end
    
    private
      # Override this
      def store_data(data); end
    
      # Override this
      def initial_data
        []
      end
    
      # This is an override of GridPanel#on_data_changed
      def on_data_changed
        store_data(data_class.all_columns)
      end

  end
end
