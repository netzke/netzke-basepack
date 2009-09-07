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
      
        # Model helpers
        const_name = "Netzke::Helpers::#{data_class.name}"
        model_extensions = const_name.constantize rescue nil
        data_class.send(:include, model_extensions) if model_extensions && !data_class.include?(model_extensions)
      end
    end

    # Returns columns that are exposed by the class and the helpers
    def predefined_columns
      helper_module = "Netzke::Helpers::#{short_widget_class_name}#{data_class.name}".constantize rescue nil
      
      data_class_columns = data_class && data_class.column_names.map(&:to_sym) || []
      
      if helper_module
        exposed_attributes = helper_module.respond_to?(:exposed_attributes) ? normalize_array_of_columns(helper_module.exposed_attributes) : nil
        virtual_attributes = helper_module.respond_to?(:virtual_attributes) ? helper_module.virtual_attributes : []
        excluded_attributes = helper_module.respond_to?(:excluded_attributes) ? helper_module.excluded_attributes : []
        attributes_config = helper_module.respond_to?(:attributes_config) ? helper_module.attributes_config : {}
        
        res = exposed_attributes || data_class_columns + virtual_attributes
        
        res = normalize_columns(res)
        
        res.reject!{ |c| excluded_attributes.include? c[:name] }

        res.map!{ |c| c.merge!(attributes_config[c[:name]] || {})}
      else
        res = normalize_columns(data_class_columns)
      end
      
      res
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
      field.is_a?(Symbol) ? {:name => field} : field
    end
    
    # From symbols to config hashes
    def normalize_columns(items)
      items.map{|c| normalize_column(c)}
    end
    
  end
end