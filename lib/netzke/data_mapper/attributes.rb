module Netzke
  module DataMapper
    module Attributes
      extend ActiveSupport::Concern

      included do
        class_attribute :netzke_declared_attr
        self.netzke_declared_attr = []

        class_attribute :netzke_excluded_attr
        self.netzke_excluded_attr = []

        class_attribute :netzke_exposed_attr
      end

      module ClassMethods
        def data_adapter
          Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(self).new(self)
        end

        # Define or configure an attribute.
        # Example:
        #   netzke_attribute :recent, :type => :boolean, :read_only => true
        def netzke_attribute(name, options = {})
          name = name.to_s
          options[:attr_type] = options.delete(:type) || options.delete(:attr_type) || :string
          declared_attrs = self.netzke_declared_attr.dup
          # if the attr was declared already, simply merge it with the new options
          existing = declared_attrs.detect{ |va| va[:name] == name }
          if existing
            existing.merge!(options)
          else
            attr_config = {:name => name}.merge(options)
            # if primary_key, insert in front, otherwise append
            if name == self.primary_key
              declared_attrs.insert(0, attr_config)
            else
              declared_attrs << {:name => name}.merge(options)
            end
          end
          self.netzke_declared_attr = declared_attrs
        end

        # Exclude attributes from being picked up by grids and forms.
        # Accepts an array of attribute names (as symbols).
        # Example:
        #   netzke_expose_attributes :created_at, :updated_at, :crypted_password
        def netzke_exclude_attributes(*args)
          self.netzke_excluded_attr = args.map(&:to_s)
        end

        # Explicitly expose attributes that should be picked up by grids and forms.
        # Accepts an array of attribute names (as symbols).
        # Takes precedence over <tt>netzke_exclude_attributes</tt>.
        # Example:
        #   netzke_expose_attributes :name, :role__name
        def netzke_expose_attributes(*args)
          self.netzke_exposed_attr = args.map(&:to_s)
        end

        # Returns the attributes that will be picked up by grids and forms.
        def netzke_attributes
          exposed = netzke_exposed_attributes
          exposed ? netzke_attrs_in_forced_order(exposed) : netzke_attrs_in_natural_order
        end

        def netzke_attribute_hash
          netzke_attributes.inject({}){ |r,a| r.merge(a[:name].to_sym => a) }
        end

        def netzke_exposed_attributes
          exposed = self.netzke_exposed_attr
          if exposed && !exposed.include?(self.primary_key)
            # automatically declare primary key as a netzke attribute
            netzke_attribute(self.primary_key)
            exposed.insert(0, self.primary_key)
          end
          exposed
        end

        def primary_key
          key.first.name.to_s
        end

        def column_names
          properties.map(&:name).map(&:to_s)
        end

        def columns
          properties
        end

        def columns_hash
          properties.inject({}) { |hsh, prop|
            hsh[prop.name.to_s] = prop
            hsh
          }
        end

        def property_with(name)
          properties.find{|p| p.name == name.to_sym}
        end

        private
        def netzke_attrs_in_forced_order(attrs)
          attrs.collect do |attr_name|
            declared = self.netzke_declared_attr.detect { |va| va[:name] == attr_name } || {}
            in_columns_hash = columns_hash[attr_name] && {:name => attr_name, :attr_type => data_adapter.map_type(columns_hash[attr_name].class), :default_value => columns_hash[attr_name].default} || {} # {:virtual => true} # if nothing found in columns, mark it as "virtual" or not?
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
            declared_attrs = self.netzke_declared_attr

            column_names.map do |name|
              c = {:name => name, :attr_type => data_adapter.map_type(property_with(name).class)}

              # If it's named as foreign key of some association, then it's an association column
              # assoc = reflect_on_all_associations.detect { |a| foreign_key_for_assoc(a) == c[:name] }
              assoc = relationships.detect { |r| r.child_key.first.name.to_s == c[:name] }
              if assoc
                assoc_class = assoc.parent_model
                candidates = %w{name title label} << c[:name]
                assoc_method = candidates.detect{|m| (assoc_class.instance_methods.map(&:to_s) + assoc_class.column_names).include?(m) }
                c[:name] = "#{assoc.name}__#{assoc_method}"
                c[:attr_type] = data_adapter.map_type(columns_hash[assoc_method]).try(:class) || :string # when it's an instance method rather than a column, fall back to :string
              end

              # auto set up the default value from the column settings
              c.merge!(:default_value => property_with(name).default) if property_with(name).default

              # if there's a declared attr with the same name, simply merge it with what's taken from the model's columns
              if declared = declared_attrs.detect{ |va| va[:name] == c[:name] }
                c.merge!(declared)
                declared_attrs.delete(declared)
              end
              c
            end +
            declared_attrs
          ).reject { |attr| self.netzke_excluded_attr.include?(attr[:name]) }
        end

        def association_attr?(attr_name)
          !!attr_name.index("__") # probably we can't do much better than this, as we don't know at this moment if the associated model has a specific attribute, and we don't really want to find it out
        end
      end

      # Transforms a record to array of values according to the passed attributes
      def netzke_array(attributes)
        res = []
        for a in attributes
          next if a[:included] == false
          res << value_for_attribute(a, a[:nested_attribute])
        end
        res
      end

      def netzke_json
        netzke_hash(self.class.netzke_attributes).to_nifty_json
      end

      # Accepts both hash and array of attributes
      def netzke_hash(attributes)
        res = {}
        for a in (attributes.is_a?(Hash) ? attributes.values : attributes)
          next if a[:included] == false
          res[a[:name].to_sym] = self.value_for_attribute(a, a[:nested_attribute])
        end
        res
      end

      # Fetches the value specified by an (association) attribute
      # If +through_association+ is true, get the value of the association by provided method, *not* the associated record's id
      # E.g., author__name with through_association set to true may return "Vladimir Nabokov", while with through_association set to false, it'll return author_id for the current record
      def value_for_attribute(a, through_association = false)
        v = if a[:getter]
              a[:getter].call(self)
            elsif respond_to?("#{a[:name]}")
              send("#{a[:name]}")
            elsif is_association_attr?(a)
              split = a[:name].to_s.split(/\.|__/)
              assoc = self.class.relationships[split.first.to_sym]

              if through_association
                split.inject(self) do |r,m| # TODO: do we really need to descend deeper than 1 level?
                  if r.respond_to?(m)
                    r.send(m)
                  else
                    ::Rails.logger.debug "Netzke::Basepack: Wrong attribute name: #{a[:name]}" unless r.nil?
                    nil
                  end
                end
              else
                self.send assoc.child_key.first.name
              end
            end

        # a work-around for to_json not taking the current timezone into account when serializing ActiveSupport::TimeWithZone
        v = v.to_datetime.to_s(:db) if [ActiveSupport::TimeWithZone].include?(v.class)
        v = v.to_s(:db) if [DateTime, Date].include?(v.class)
        v
      end

      # Assigns new value to an (association) attribute
      def set_value_for_attribute(a, v)
        v = v.to_time_in_current_zone if v.is_a?(Date) # convert Date to Time

        if a[:setter]
          a[:setter].call(self, v)
        elsif respond_to?("#{a[:name]}=")
          send("#{a[:name]}=", v)
        elsif is_association_attr?(a)
          split = a[:name].to_s.split(/\.|__/)
          if a[:nested_attribute]
            # We want:
            #     set_value_for_attribute({:name => :assoc_1__assoc_2__method, :nested_attribute => true}, 100)
            # =>
            #     self.assoc_1.assoc_2.method = 100
            split.inject(self) { |r,m| m == split.last ? (r && r.send("#{m}=", v) && r.save) : r.send(m) }
          else
            if split.size == 2
              # search for association and assign it to self
              assoc_name, assoc_method = split
              relationship=self.class.relationships[assoc_name]

              if relationship
                if relationship.kind_of? ::DataMapper::Associations::OneToOne::Relationship
                  assoc_instance=self.send(assoc_name)
                  if assoc_instance
                    assoc_instance.send("#{assoc_method}=", v)
                    assoc_instance.save # what should we do when this fails?..
                  else
                    # what should we do in this case?
                  end
                else
                  self.send("#{self.class.data_adapter.foreign_key_for assoc_name}=", v)
                end
              else
                ::Rails.logger.debug "Netzke::Basepack: Association #{assoc} is not known for class #{self.class.name}"
              end
            else
              ::Rails.logger.debug "Netzke::Basepack: Wrong attribute name: #{a[:name]}"
            end
          end
        end
      end

      protected
      # Returns true if passed attribute is an "association attribute"
      def is_association_attr?(a)
        # maybe the check is too simplistic, but will do for now
        !!a[:name].to_s.index("__")
      end
    end
  end
end
