module Netzke::ActiveRecord::Attributes
  module ClassMethods
    
    # Define or configure an attribute.
    # Example:
    #   netzke_attribute :recent, :type => :boolean, :read_only => true
    def netzke_attribute(name, options = {})
      name = name.to_s
      options[:attr_type] = options.delete(:type) || :string
      declared_attrs = read_inheritable_attribute(:netzke_declared_attributes) || []
      # if the attr was declared already, simply merge it with the new options
      existing = declared_attrs.detect{ |va| va[:name] == name }
      if existing
        existing.merge!(options)
      else
        declared_attrs << {:name => name}.merge(options)
      end
      write_inheritable_attribute(:netzke_declared_attributes, declared_attrs)
    end
    
    # Exclude attributes from being picked up by grids and forms.
    # Accepts an array of attribute names (as symbols).
    # Example:
    #   netzke_expose_attributes :created_at, :updated_at, :crypted_password
    def netzke_exclude_attributes(*args)
      write_inheritable_attribute(:netzke_excluded_attributes, args.map(&:to_s))
    end
    
    # Explicitly expose attributes that should be picked up by grids and forms.
    # Accepts an array of attribute names (as symbols).
    # Takes precedence over <tt>netzke_exclude_attributes</tt>.
    # Example:
    #   netzke_expose_attributes :name, :role__name
    def netzke_expose_attributes(*args)
      write_inheritable_attribute(:netzke_exposed_attributes, args.map(&:to_s))
    end
    
    # Returns the attributes that will be picked up by grids and forms.
    def netzke_attributes
      exposed = read_inheritable_attribute(:netzke_exposed_attributes)
      exposed ? netzke_attrs_in_forced_order(exposed) : netzke_attrs_in_natural_order
    end
    
    private
      def netzke_declared_attributes
        read_inheritable_attribute(:netzke_declared_attributes) || []
      end
    
      def netzke_excluded_attributes
        read_inheritable_attribute(:netzke_excluded_attributes) || []
      end

      def netzke_attrs_in_forced_order(attrs)
        attrs.collect do |attr_name|
          declared = netzke_declared_attributes.detect { |va| va[:name] == attr_name } || {}
          in_columns_hash = columns_hash[attr_name] && {:name => attr_name, :attr_type => columns_hash[attr_name].type, :default_value => columns_hash[attr_name].default} || {} # {:virtual => true} # if nothing found in columns, mark it as "virtual" or not?
          if in_columns_hash.empty?
            # If not among the model columns, it's either virtual, or an association
            merged = association_attr?(attr_name) ? declared.merge!(:name => attr_name) : declared.merge(:virtual => true)
          else
            # .. otherwise merge with what's declared
            merged = in_columns_hash.merge(declared)
          end
          
          # We didn't find it among declared, nor among the model columns, nor does it seem association attribute
          merged[:name].nil? && raise(ArgumentError, "Unknown attribute '#{attr_name}' for model #{self.name}", caller)
          
          merged
        end
      end
      
      # Returns netzke attributes in the order of columns in the table, followed by extra declared attributes
      # Detects one-to-many association columns and replaces the name of the column with association column name (Netzke style), e.g.:
      # 
      #   role_id => role__name
      def netzke_attrs_in_natural_order
        (
          declared_attrs = netzke_declared_attributes
          column_names.map do |name|
            c = {:name => name, :attr_type => columns_hash[name].type}
            
            # If it's named as foreign key of some association, then it's an association column
            assoc = reflect_on_all_associations.detect{|a| a.primary_key_name == c[:name]}

            if assoc && !assoc.options[:polymorphic]
              assoc_method = %w{name title label id}.detect{|m| (assoc.klass.instance_methods + assoc.klass.column_names).include?(m) } || assoc.klass.primary_key
              c[:name] = "#{assoc.name}__#{assoc_method}"
              c[:attr_type] = assoc.klass.columns_hash[assoc_method].type
            end
            
            # auto set up the default value from the column settings
            c.merge!(:default_value => columns_hash[name].default) if columns_hash[name].default
            
            # if there's a declared attr with the same name, simply merge it with what's taken from the model's columns
            if declared = declared_attrs.detect{ |va| va[:name] == c[:name] }
              c.merge!(declared)
              declared_attrs.delete(declared)
            end
            c
          end +
          declared_attrs
        ).reject { |attr| netzke_excluded_attributes.include?(attr[:name]) }
      end
      
      def association_attr?(attr_name)
        !!attr_name.index("__") # probably we can't do much better than this, as we don't know at this moment if the associated model has a specific attribute, and we don't really want to find it out
      end
      
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
  end
end