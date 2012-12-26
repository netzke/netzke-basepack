module Netzke::Basepack::DataAdapters
  # Implementation of Netzke::Basepack::DataAdapters::AbstractAdapter
  class ActiveRecordAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class <= ActiveRecord::Base
    end

    def primary_key_name
      @model_class.primary_key.to_s
    end

    def model_attributes
      @model_class.column_names.map do |column_name|
        {name: column_name, attr_type: @model_class.columns_hash[column_name].type}.tap do |c|

          # If it's named as foreign key of some association, then it's an association column
          assoc = @model_class.reflect_on_all_associations.detect { |a| a.foreign_key == c[:name] }

          if assoc && !assoc.options[:polymorphic]
            candidates = %w{name title label} << assoc.foreign_key
            assoc_method = candidates.detect{|m| (assoc.klass.instance_methods.map(&:to_s) + assoc.klass.column_names).include?(m) }
            c[:name] = "#{assoc.name}__#{assoc_method}"
          end

          c[:attr_type] = attr_type(c[:name])

          # auto set up the default value from the column settings
          c[:default_value] = @model_class.columns_hash[column_name].default if @model_class.columns_hash[column_name].default
        end
      end
    end

    # WIP
    def attribute_names
      @model_class.column_names
    end

    def primary_key_attr?(a)
      a[:name].to_s == @model_class.primary_key.to_s
    end

    def human_attribute_name(attr_name)
      @model_class.human_attribute_name(attr_name)
    end

    def primary_key
      @model_class.primary_key
    end
    ## E_WIP

    def attr_type(attr_name)
      association_attr?(attr_name) ? :integer : (@model_class.columns_hash[attr_name.to_s].try(:type) || :string)
    end

    def get_records(params, columns=[])
      @cls = columns
      # build initial relation based on passed params
      relation = get_relation(params)

      # addressing the n+1 query problem
      columns.each do |c|
        assoc, method = c[:name].split('__')
        relation = relation.includes(assoc.to_sym) if method
      end

      # apply sorting if needed
      if params[:sort] && sort_params = params[:sort].first
        assoc, method = sort_params["property"].split('__')
        dir = sort_params["direction"].downcase

        # if a sorting scope is set, call the scope with the given direction
        column = columns.detect { |c| c[:name] == sort_params["property"] }
        if column.has_key?(:sorting_scope)
          relation = relation.send(column[:sorting_scope].to_sym, dir.to_sym)
        else
          relation = if method.nil?
                       relation.order("#{@model_class.table_name}.#{assoc} #{dir}")
                     else
                       assoc = @model_class.reflect_on_association(assoc.to_sym)
                       relation.joins(assoc.name).order("#{assoc.klass.table_name}.#{method} #{dir}")
                     end
        end
      end

      page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
      if params[:limit]
        relation.offset(params[:start]).limit(params[:limit])
      else
        relation.all
      end
    end

    def count_records(params, columns=[])
      # build initial relation based on passed params
      relation = get_relation(params)

      # addressing the n+1 query problem
      columns.each do |c|
        assoc, method = c[:name].split('__')
        relation = relation.includes(assoc.to_sym) if method
      end

      relation.count
    end

    def get_assoc_property_type assoc_name, prop_name
      if prop_name && assoc=@model_class.reflect_on_association(assoc_name)
        assoc_column = assoc.klass.columns_hash[prop_name.to_s]
        assoc_column.try(:type)
      end
    end

    def virtual_attribute?(c)
      assoc_name, asso = c[:name].split('__')
      assoc, assoc_method = assoc_and_assoc_method_for_attr(c[:name])

      if assoc
        return !assoc.klass.column_names.map(&:to_sym).include?(assoc_method.to_sym)
      else
        return !@model_class.column_names.map(&:to_sym).include?(c[:name].to_sym)
      end
    end

    def combo_data(attr, query = "")
      assoc, assoc_method = assoc_and_assoc_method_for_attr(attr[:name])

      if assoc
        # Options for an asssociation attribute

        relation = assoc.klass.scoped
        relation = relation.extend_with(attr[:scope]) if attr[:scope]

        if assoc.klass.column_names.include?(assoc_method)
          # apply query
          relation = relation.where(["#{assoc_method} like ?", "%#{query}%"]) if query.present?
          relation.all.map{ |r| [r.id, r.send(assoc_method)] }
        else
          # an expensive search!
          relation.all.map{ |r| [r.id, r.send(assoc_method)] }.select{ |id,value| value =~ /^#{query}/ }
        end

      else
        distinct_combo_values(attr, query)
      end
    end

    def distinct_combo_values(attr, query)
      records = query.empty? ? @model_class.find_by_sql("select distinct #{attr[:name]} from #{@model_class.table_name}") : @model_class.find_by_sql("select distinct #{attr[:name]} from #{@model_class.table_name} where #{attr[:name]} like '#{query}%'")
      records.map{|r| [r.send(attr[:name]), r.send(attr[:name])]}
    end
    protected :distinct_combo_values

    def foreign_key_for assoc_name
      @model_class.reflect_on_association(assoc_name.to_sym).foreign_key
    end

    # Returns the model class for association columns
    def class_for assoc_name
      @model_class.reflect_on_association(assoc_name.to_sym).klass
    end

    def destroy(ids)
      @model_class.destroy(ids)
    end

    def find_record(id)
      @model_class.where(@model_class.primary_key => id).first
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      foreign_keys = {}
      @model_class.reflect_on_all_associations(:belongs_to).map{ |r|
        foreign_keys[r.association_foreign_key.to_sym] = r.name
      }
      foreign_keys
    end

    def move_records(params)
      if defined?(ActsAsList) && @model_class.ancestors.include?(ActsAsList::InstanceMethods)
        ids = JSON.parse(params[:ids]).reverse
        ids.each_with_index do |id, i|
          r = @model_class.find(id)
          r.insert_at(params[:new_index].to_i + i + 1)
        end
        on_data_changed
      else
        raise RuntimeError, "Model class should implement 'acts_as_list' to support reordering records"
      end
    end

    def record_to_array(r, attrs)
      [].tap do |res|
        attrs.each do |a|
          res << record_value_for_attribute(r, a, a[:nested_attribute]) if a[:included] != false # :included ever used?..
        end
      end
    end

    def record_to_hash(r, attrs)
      {}.tap do |res|
        attrs.each do |a|
          res[a[:name].to_sym] = record_value_for_attribute(r, a, a[:nested_attribute]) if a[:included] != false
        end
      end
    end

    # def assoc_values(r, attr_hash) #:nodoc:
    #   @_assoc_values ||= {}.tap do |values|
    #     attr_hash.each_pair do |name,c|
    #       values[name] = record_value_for_attribute(r, c, true) if association_attr?(c)
    #     end
    #   end
    # end

    def record_value_for_attribute(r, a, through_association = false)
      v = if a[:getter]
        a[:getter].call(r)
      elsif r.respond_to?("#{a[:name]}")
        r.send("#{a[:name]}")
      elsif association_attr?(a)
        split = a[:name].to_s.split(/\.|__/)
        assoc = @model_class.reflect_on_association(split.first.to_sym)
        if through_association
          split.inject(r) do |r,m| # TODO: do we really need to descend deeper than 1 level?
            if r.respond_to?(m)
              r.send(m)
            else
              logger.debug "Netzke::Basepack: Wrong attribute name: #{a[:name]}" unless r.nil?
              nil
            end
          end
        else
          r.send("#{assoc.options[:foreign_key] || assoc.name.to_s.foreign_key}")
        end
      end

      # a work-around for to_json not taking the current timezone into account when serializing ActiveSupport::TimeWithZone
      v = v.to_datetime.to_s(:db) if [ActiveSupport::TimeWithZone].include?(v.class)

      v
    end

    def set_record_value_for_attribute(r, a, v, role = :default)
      v = v.to_time_in_current_zone if v.is_a?(Date) # convert Date to Time

      if a[:setter]
        a[:setter].call(r, v)
      elsif r.respond_to?("#{a[:name]}=") && attribute_mass_assignable?(a[:name], role)
        r.send("#{a[:name]}=", v)
      elsif association_attr?(a)
        split = a[:name].to_s.split(/\.|__/)
        if a[:nested_attribute]
          # We want:
          #     set_value_for_attribute({:name => :assoc_1__assoc_2__method, :nested_attribute => true}, 100)
          # =>
          #     r.assoc_1.assoc_2.method = 100
          split.inject(r) { |r,m| m == split.last ? (r && r.send("#{m}=", v) && r.save) : r.send(m) }
        else
          if split.size == 2
            # search for association and assign it to r
            assoc = @model_class.reflect_on_association(split.first.to_sym)
            assoc_method = split.last
            if assoc
              if assoc.macro == :has_one
                assoc_instance = r.send(assoc.name)
                if assoc_instance
                  assoc_instance.send("#{assoc_method}=", v)
                  assoc_instance.save # what should we do when this fails?..
                else
                  # what should we do in this case?
                end
              else

                # set the foreign key to the passed value
                # not that if a negative value is passed, we reset the association (set it to nil)
                r.send("#{assoc.foreign_key}=", v.to_i < 0 ? nil : v) if attribute_mass_assignable?(assoc.foreign_key, role)
              end
            else
              logger.debug "Netzke::Basepack: Association #{assoc} is not known for class #{@data_class}"
            end
          else
            logger.debug "Netzke::Basepack: Wrong attribute name: #{a[:name]}"
          end
        end
      end
    end

    # Returns association and association method for a column
    def assoc_and_assoc_method_for_attr(column_name)
      assoc_name, assoc_method = column_name.split('__')
      assoc = @model_class.reflect_on_association(assoc_name.to_sym) if assoc_method
      [assoc, assoc_method]
    end
    protected :assoc_and_assoc_method_for_attr


    # An ActiveRecord::Relation instance encapsulating all the necessary conditions.
    def get_relation(params = {})
      @arel = @model_class.arel_table

      relation = @model_class.scoped

      relation = apply_column_filters(relation, params[:filter]) if params[:filter]

      query = params[:query] && ActiveSupport::JSON.decode(params[:query])

      if query.present?
        # array of arrays of conditions that should be joined by OR
        and_predicates = query.map do |conditions|
          predicates_for_and_conditions(conditions)
        end

        # join them by OR
        predicates = and_predicates[1..-1].inject(and_predicates.first){ |r,c| r.or(c) }
      end

      relation = relation.where(predicates)

      relation = relation.extend_with(params[:scope]) if params[:scope]

      relation
    end
    protected :get_relation

    # Parses and applies grid column filters, calling consequent "where" methods on the passed relation.
    # Returns the updated relation.
    #
    # Example column grid data:
    #
    #     {"0" => {
    #       "data" => {
    #         "type" => "numeric",
    #         "comparison" => "gt",
    #         "value" => 10 },
    #       "field" => "id"
    #     },
    #     "1" => {
    #       "data" => {
    #         "type" => "string",
    #         "value" => "pizza"
    #       },
    #       "field" => "food_name"
    #     }}
    #
    # This will result in:
    #
    #      relation.where(["id > ?", 10]).where(["food_name like ?", "%pizza%"])
    def apply_column_filters(relation, column_filter)
      res = relation
      operator_map = {"lt" => "<", "gt" => ">", "eq" => "="}

      # these are still JSON-encoded due to the migration to Ext.direct
      column_filter=JSON.parse(column_filter)
      column_filter.each do |v|
        assoc, method = v["field"].split('__')
        if method
          assoc = @model_class.reflect_on_association(assoc.to_sym)
          if assoc.klass.column_names.include? method
            field = [assoc.klass.table_name, method].join('.').to_sym
          end
        else
          field = assoc.to_sym
        end

        value = v["value"]

        op = operator_map[v['comparison']]

        col_filter = @cls.inject(nil) { |fil, col|
          if col.is_a?(Hash) && col[:filter_with] && col[:name].to_sym == v['field'].to_sym
            fil = col[:filter_with]
          end
          fil
        }
        if col_filter
          res = col_filter.call(res, value, op)
          col_filter = nil
          next
        end
        case v["type"]
        when "string"
          res = res.where(["#{field} like ?", "%#{value}%"])
        when "date"
          # convert value to the DB date
          value.match /(\d\d)\/(\d\d)\/(\d\d\d\d)/
          res = res.where("#{field} #{op} ?", "#{$3}-#{$1}-#{$2}")
        when "numeric"
          res = res.where(["#{field} #{op} ?", value])
        else
          res = res.where(["#{field} = ?", value])
        end
      end

      res
    end

    protected :apply_column_filters

    def predicates_for_and_conditions(conditions)
      return nil if conditions.empty?

      predicates = conditions.map do |q|
        value = q["value"]
        case q["operator"]
        when "contains"
          @arel[q["attr"]].matches "%#{value}%"
        else
          if value == false || value == true
            @arel[q["attr"]].eq(value ? 1 : 0)
          else
            @arel[q["attr"]].send(q["operator"], value)
          end
        end
      end

      # join them by AND
      predicates[1..-1].inject(predicates.first){ |r,p| r.and(p)  }
    end
    protected :predicates_for_and_conditions

    # Whether an attribute is mass assignable. As second argument optionally takes the role.
    def attribute_mass_assignable?(attr_name, role = :default)
      @model_class.accessible_attributes(role).empty? ? !@model_class.protected_attributes(role).include?(attr_name.to_s) : @model_class.accessible_attributes(role).include?(attr_name.to_s)
    end
    protected :attribute_mass_assignable?
  end
end
