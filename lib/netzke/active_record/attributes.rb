module Netzke
  module ActiveRecord
    module Attributes
      extend ActiveSupport::Concern

      module ClassMethods
        def data_adapter
          @data_adapter = Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(self).new(self)
        end

      protected

        # FIXME: this duplicates with is_association_attr? below
        def association_attr?(attr_name)
          !!attr_name.index("__") # probably we can't do much better than this, as we don't know at this moment if the associated model has a specific attribute, and we don't really want to find it out
        end
      end

      # Transforms a record to array of values according to the passed attributes
      def netzke_array(attributes = self.class.netzke_attributes)
        res = []
        for a in attributes
          next if a[:included] == false
          res << value_for_attribute(a, a[:nested_attribute])
        end
        res
      end

      def netzke_json
        netzke_hash.to_nifty_json
      end

      # Accepts both hash and array of attributes
      def netzke_hash(attributes = self.class.netzke_attributes)
        res = {}
        for a in (attributes.is_a?(Hash) ? attributes.values : attributes)
          next if a[:included] == false
          res[a[:name].to_sym] = self.value_for_attribute(a, a[:nested_attribute])
        end
        res
      end

      # TODO: document
      def netzke_association_values(attr_hash) #:nodoc:
        @_netzke_association_values ||= {}.tap do |values|
          attr_hash.each_pair do |name,c|
            values[name] = value_for_attribute(c, true) if is_association_attr?(c)
          end
        end
        #final_columns.select{ |c| c[:name].index("__") }.each.inject({}) do |r,c|
          #r.merge(c[:name] => record.value_for_attribute(c, true))
        #end
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
          assoc = self.class.reflect_on_association(split.first.to_sym)
          if through_association
            split.inject(self) do |r,m| # TODO: do we really need to descend deeper than 1 level?
              if r.respond_to?(m)
                r.send(m)
              else
                logger.debug "Netzke::Basepack: Wrong attribute name: #{a[:name]}" unless r.nil?
                nil
              end
            end
          else
            self.send("#{assoc.options[:foreign_key] || assoc.name.to_s.foreign_key}")
          end
        end

        # a work-around for to_json not taking the current timezone into account when serializing ActiveSupport::TimeWithZone
        v = v.to_datetime.to_s(:db) if [ActiveSupport::TimeWithZone].include?(v.class)

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
              assoc = self.class.reflect_on_association(split.first.to_sym)
              assoc_method = split.last
              if assoc
                if assoc.macro == :has_one
                  assoc_instance = self.send(assoc.name)
                  if assoc_instance
                    assoc_instance.send("#{assoc_method}=", v)
                    assoc_instance.save # what should we do when this fails?..
                  else
                    # what should we do in this case?
                  end
                else
                  self.send("#{assoc.options[:foreign_key] || assoc.name.to_s.foreign_key}=", v)
                end
              else
                logger.debug "Netzke::Basepack: Association #{assoc} is not known for class #{self.class.name}"
              end
            else
              logger.debug "Netzke::Basepack: Wrong attribute name: #{a[:name]}"
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
