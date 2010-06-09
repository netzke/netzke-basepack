require "netzke/active_record/data_accessor"

module Netzke
  # This module is included into such data-driven widgets as GridPanel, FormPanel, etc. It provides for
  # flexible pre-configuration of (virtual) attributes.
  #
  # TODO: show examples of how to create the helpers
  module DataAccessor
    
    # This method should be called from the constructor of the widget. It dynamically includes:
    # 1) helpers into the data model for this widget; those may contain instance methods used as virtual attributes
    # 2) generic (used by all "data accessor" widgets) extensions into the data model for this widget
    def apply_helpers
      # Generic extensions to the data model
      if data_class # because some widgets, like FormPanel, may have it optional
        data_class.send(:include, Netzke::ActiveRecord::DataAccessor) if !data_class.include?(Netzke::ActiveRecord::DataAccessor)
        #       
        # # Model helpers
        # model_extensions = "Netzke::Helpers::#{data_class.name}".constantize rescue nil
        # data_class.send(:include, model_extensions) if model_extensions && !data_class.include?(model_extensions)
        module_name = "Netzke::ModelInjections::#{data_class.name}#{short_widget_class_name}"
        injector_module = "Netzke::ModelInjections::#{data_class.name}#{short_widget_class_name}".constantize rescue nil
        data_class.send(:include, injector_module) if injector_module && !data_class.include?(injector_module)
        injector_module = "Netzke::ModelInjections::#{short_widget_class_name}".constantize rescue nil
        data_class.send(:include, injector_module) if injector_module && !data_class.include?(injector_module)
      end
    end
    
    # [:col1, "col2", {:name => :col3}] =>
    #   [{:name => "col1"}, {:name => "col2"}, {:name => "col3"}]
    def normalize_attr_config(cols)
      cols.map do |c|
        c.is_a?(Symbol) || c.is_a?(String) ? {:name => c.to_s} : c.merge(:name => c[:name].to_s)
      end
    end

    # Make sure we have keys as symbols, not strings
    def normalize_array_of_columns(arry)
      arry.map do |f| 
        if f.is_a?(Hash)
          f.symbolize_keys
        else
          f.to_sym
        end
      end
    end
    
    # From symbol to config hash
    def normalize_column(field)
      field.is_a?(Symbol) ? {:name => field.to_s} : field
    end
    
    # From symbols to config hashes
    def normalize_columns(items)
      items.map{|c| normalize_column(c)}
    end
    
  end
end