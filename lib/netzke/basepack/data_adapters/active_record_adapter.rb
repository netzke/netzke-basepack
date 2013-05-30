module Netzke::Basepack::DataAdapters
  # Implementation of {Netzke::Basepack::DataAdapters::AbstractAdapter}
  class ActiveRecordAdapter < AbstractAdapter
    def self.for_class?(model_class)
      model_class && model_class <= ActiveRecord::Base
    end

    def new_record(params = {})
      @model_class.new(params)
    end

    def primary_key
      @model_class.primary_key.to_s
    end

    def model_attributes
      @_model_attributes ||= attribute_names.map do |column_name|
        # If it's named as foreign key of some association, then it's an association column
        assoc = @model_class.reflect_on_all_associations.detect { |a| a.foreign_key == column_name }

        if assoc && !assoc.options[:polymorphic]
          candidates = %w{name title label} << assoc.klass.primary_key
          assoc_method = candidates.detect{|m| (assoc.klass.instance_methods.map(&:to_s) + assoc.klass.column_names).include?(m) }
          :"#{assoc.name}__#{assoc_method}"
        else
          column_name.to_sym
        end
        # auto set up the default value from the column settings
        # c[:default_value] = @model_class.columns_hash[column_name].default if @model_class.columns_hash[column_name].default
      end
    end

    def attribute_names
      @model_class.column_names
    end

    def human_attribute_name(attr_name)
      @model_class.human_attribute_name(attr_name)
    end

    def attr_type(attr_name)
      association_attr?(attr_name) ? :integer : (@model_class.columns_hash[attr_name.to_s].try(:type) || :string)
    end

    # Implementation for {AbstractAdapter#get_records}
    def get_records(params, columns=[])
      # build initial relation based on passed params
      relation = get_relation(params)

      # addressing the n+1 query problem
      columns.each do |c|
        assoc, method = c[:name].split('__')
        relation = relation.includes(assoc.to_sym) if method
      end

      # apply sorting if needed
      if params[:sorters] && sort_params = params[:sorters].first
        dir = sort_params["direction"].downcase
        column = columns.detect { |c| c[:name] == sort_params["property"] }
        relation = apply_sorting(relation, column, dir)
      end

      #page = params[:limit] ? params[:start].to_i/params[:limit].to_i + 1 : 1
      if params[:limit]
        relation.offset(params[:start]).limit(params[:limit])
      else
        relation.all
      end
    end

    def apply_sorting(relation, column, dir)
      assoc, method = column[:name].split('__')

      # if a sorting scope is set, call the scope with the given direction
      if column.has_key?(:sorting_scope)
        relation = relation.send(column[:sorting_scope].to_sym, dir.to_sym)
      else
        relation = if method.nil?
          relation.order("#{@model_class.table_name}.#{assoc} #{dir}")
        else
          assoc = @model_class.reflect_on_association(assoc.to_sym)
          relation.includes(assoc.name).order("#{assoc.klass.table_name}.#{method} #{dir}")
        end
      end

      relation
    end

    def count_records(params, columns=[])
      # if get_relation was called before (e.g. through get_records), don't call it again, just use its latest result
      relation = @relation || get_relation(params)

      # addressing the n+1 query problem
      columns.each do |c|
        assoc, method = c[:name].split('__')
        relation = relation.includes(assoc.to_sym) if method
      end

      relation.count
    end

    def get_assoc_property_type assoc_name, prop_name
      if prop_name && assoc = @model_class.reflect_on_association(assoc_name)
        assoc_column = assoc.klass.columns_hash[prop_name.to_s]
        assoc_column.try(:type)
      end
    end

    def virtual_attribute?(c)
      assoc_name, asso = c[:name].split('__')
      assoc, assoc_method = assoc_and_assoc_method_for_attr(c[:name])

      if assoc
        return !assoc.klass.column_names.include?(assoc_method)
      else
        return !@model_class.column_names.include?(c[:name])
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
          assoc_arel_table = assoc.klass.arel_table

          relation = relation.where(assoc_arel_table[assoc_method].matches("%#{query}%"))  if query.present?
          relation.all.map{ |r| [r.id, r.send(assoc_method)] }
        else
          query.downcase!
          # an expensive search!
          relation.all.map{ |r| [r.id, r.send(assoc_method)] }.select{ |id,value| value.downcase.include?(query) }
        end

      else
        distinct_combo_values(attr, query)
      end
    end

    def distinct_combo_values(attr, query)
      records = query.empty? ? @model_class.find_by_sql("select distinct #{attr[:name]} from #{@model_class.table_name}") : @model_class.find_by_sql("select distinct #{attr[:name]} from #{@model_class.table_name} where #{attr[:name]} like '#{query}%'")
      records.map{|r| [r.send(attr[:name]), r.send(attr[:name])]}
    end

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

    # Returns a record by id.
    # Respects the following options:
    # * scope - will only return a record if it falls into the provided scope
    def find_record(id, options = {})
      scope = options[:scope] || {}
      @model_class.where(primary_key => id).extend_with(scope).first
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      foreign_keys = {}
      @model_class.reflect_on_all_associations(:belongs_to).map{ |r|
        foreign_keys[r.association_foreign_key.to_sym] = r.name
      }
      foreign_keys
    end

    # FIXME
    def move_records(params)
      if defined?(ActsAsList) && @model_class.ancestors.include?(ActsAsList::InstanceMethods)
        ids = JSON.parse(params[:ids]).reverse
        ids.each_with_index do |id, i|
          r = @model_class.find(id)
          r.insert_at(params[:new_index].to_i + i + 1)
        end
        on_data_changed # copypaste nonsense
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

    def human_attribute_name(name)
      @model_class.human_attribute_name(name)
    end

    def record_value_for_attribute(r, a, through_association = false)
      v = if a[:getter]
        a[:getter].call(r)
      elsif r.respond_to?("#{a[:name]}")
        r.send("#{a[:name]}")
      elsif association_attr?(a)
        split = a[:name].to_s.split(/\.|__/)
        assoc = @model_class.reflect_on_association(split.first.to_sym)
        if through_association
          split.inject(r) do |r,m| # Do we *really* need to descend deeper than 1 level?
            return nil if r.nil?
            if r.respond_to?(m)
              r.send(m)
            else
              logger.warn "Netzke: Wrong attribute name: #{a[:name]}" unless r.nil?
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
      v = false if a[:xtype] == :checkbox && v.nil? # fix bug with checkbox

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
              logger.warn "Netzke: Association #{assoc} is not known for class #{@data_class}"
            end
          else
            logger.warn "Netzke: Wrong attribute name: #{a[:name]}"
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

    # An ActiveRecord::Relation instance encapsulating all the necessary conditions.
    def get_relation(params = {})
      relation = @model_class.scoped

      query = params[:query]

      if query.present?
        cannot_use_procs = query.size > 1

        and_predicates = query.map do |and_query|
          and_query.each do |q|
            if prok = q.delete(:proc)
              raise "Cannot use Proc conditions in OR queries" if cannot_use_procs
              relation = prok.call(relation, q[:value], q[:operator])
              and_query.delete(q)
            end
          end

          predicates_for_and_conditions(and_query)
        end

        # join them by OR
        predicates = and_predicates[1..-1].inject(and_predicates.first){ |r,c| r.or(c) }
        relation = relation.where(predicates)
      end

      if params[:filters]
        and_query = params[:filters]
        and_query.each do |q|
          if prok = q.delete(:proc)
            relation = prok.call(relation, q[:value], q[:operator])
            and_query.delete(q)
          end
        end

        # apply other, non-Proc filters
        relation = relation.where(predicates_for_and_conditions(and_query))
      end

      relation = relation.extend_with(params[:scope]) if params[:scope]

      @relation = relation
    end

    def predicates_for_and_conditions(conditions)
      return nil if conditions.empty?

      predicates = conditions.map do |q|
        q = HashWithIndifferentAccess.new(q)

        assoc, method = q["attr"].split('__')
        if method
          assoc = @model_class.reflect_on_association(assoc.to_sym)
          assoc_arel = assoc.klass.arel_table
          attr = method
          arel_table = Arel::Table.new(assoc.klass.table_name.to_sym)
        else
          attr = assoc
          arel_table = @model_class.arel_table
        end

        value = q["value"]
        op = q["operator"]

        attr_type = attr_type(attr)

        case attr_type
        when :datetime
          update_predecate_for_datetime(arel_table[attr], op, value.to_date)
        when :string, :text
          update_predecate_for_string(arel_table[attr], op, value)
        when :boolean
          update_predecate_for_boolean(arel_table[attr], op, value)
        when :date
          update_predecate_for_rest(arel_table[attr], op, value.to_date)
        else
          update_predecate_for_rest(arel_table[attr], op, value)
        end
      end

      # join them by AND
      predicates[1..-1].inject(predicates.first){ |r,p| r.and(p)  }
    end

    def update_predecate_for_boolean(table, op, value)
      table.eq(value)
    end

    def update_predecate_for_string(table, op, value)
      table.matches "%#{value}%"
    end

    def update_predecate_for_datetime(table, op, value)
      case op
      when "eq"
        table.lteq(value.end_of_day).and(table.gteq(value.beginning_of_day))
      when "gt"
        table.gt(value.end_of_day)
      when "lt"
        table.lt(value.beginning_of_day)
      when "gteq"
        table.gteq(value.beginning_of_day)
      when "lteq"
        table.lteq(value.end_of_day)
      end
    end

    def update_predecate_for_rest(table, op, value)
      legal_ops = %w[eq gt lt gteq lteq]

      if legal_ops.include?(op.to_s)
        table.send(op, value)
      else
        logger.warn("Netzke: Illegal filter operator: #{op}")
        table
      end
    end

    # Whether an attribute is mass assignable. As second argument optionally takes the role.
    def attribute_mass_assignable?(attr_name, role = :default)
      @model_class.accessible_attributes(role).empty? ? !@model_class.protected_attributes(role).include?(attr_name.to_s) : @model_class.accessible_attributes(role).include?(attr_name.to_s)
    end

  private

    def logger
      Netzke::Base.logger
    end
  end
end
