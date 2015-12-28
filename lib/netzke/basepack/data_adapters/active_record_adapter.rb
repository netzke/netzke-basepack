module Netzke::Basepack::DataAdapters
  # Implementation of {Netzke::Basepack::DataAdapters::AbstractAdapter}
  class ActiveRecordAdapter < AbstractAdapter
    def self.for_class?(model)
      model && model <= ActiveRecord::Base
    end

    def new_record(params = {})
      @model.new(params)
    end

    def primary_key
      @model.primary_key.to_s
    end

    def model_attributes
      @model_attributes ||= attribute_names.map do |column_name|
        # If it's named as foreign key of some association, then it's an association column
        assoc = @model.reflect_on_all_associations.detect { |a| a.foreign_key == column_name }

        if assoc && !assoc.options[:polymorphic]
          candidates = %w{name title label} << assoc.klass.primary_key
          assoc_method = candidates.detect{|m| (assoc.klass.instance_methods.map(&:to_s) + assoc.klass.column_names).include?(m) }
          :"#{assoc.name}__#{assoc_method}"
        else
          column_name.to_sym
        end
        # auto set up the default value from the column settings
        # c[:default_value] = @model.columns_hash[column_name].default if @model.columns_hash[column_name].default
      end
    end

    def attribute_names
      @model.column_names
    end

    def attr_type(attr_name)
      method, assoc = method_and_assoc(attr_name)
      klass = assoc.nil? ? @model : assoc.klass
      klass.columns_hash[method].try(:type) || :string
    end

    # Implementation for {AbstractAdapter#get_records}
    def get_records(params, columns=[])
      relation = get_relation(params)

      relation = fix_nplus1_problem(relation, columns)

      relation = apply_sorting(relation, columns, params[:sorters])

      relation = apply_offset(relation, params)
    end

    def count_records(params, columns=[])
      # if get_relation was called before (e.g. through get_records), don't call it again, just use its latest result
      relation = @relation || get_relation(params)

      # addressing the n+1 query problem
      columns.each do |c|
        assoc, method = c[:name].split('__')
        relation = relation.includes(assoc.to_sym).references(assoc.to_sym) if method
      end

      relation.count
    end

    def get_assoc_property_type assoc_name, prop_name
      if prop_name && assoc = @model.reflect_on_association(assoc_name)
        assoc_column = assoc.klass.columns_hash[prop_name.to_s]
        assoc_column.try(:type)
      end
    end

    def virtual_attribute?(c)
      assoc_name, asso = c[:name].split('__')
      method, assoc = method_and_assoc(c[:name])

      if assoc
        return !assoc.klass.column_names.include?(method)
      else
        return !@model.column_names.include?(c[:name])
      end
    end

    def combo_data(attr, query = "")
      method, assoc = method_and_assoc(attr[:name])

      if assoc
        # Options for an asssociation attribute

        relation = assoc.klass.all
        relation = attr[:scope].call(relation) if attr[:scope].is_a?(Proc)

        if attr[:filter_association_with]
          relation = attr[:filter_association_with].call(relation, query).to_a
          if attr[:getter]
            relation.map{ |r| [r.id, attr[:getter].call(r)] }
          else
            relation.map{ |r| [r.id, r.send(method)] }
          end
        elsif assoc.klass.column_names.include?(method)
          # apply query
          assoc_arel_table = assoc.klass.arel_table

          relation = relation.where(assoc_arel_table[method].matches("%#{query}%"))  if query.present?
          relation.to_a.map{ |r| [r.id, r.send(method)] }
        else
          query.downcase!
          # an expensive search!
          relation.to_a.map{ |r| [r.id, r.send(method)] }.select{ |id,value| value.to_s.downcase.include?(query) }
        end

      else
        distinct_combo_values(attr, query)
      end
    end

    def distinct_combo_values(attr, query)
      records = query.empty? ? @model.find_by_sql("select distinct #{attr[:name]} from #{@model.table_name}") : @model.find_by_sql("select distinct #{attr[:name]} from #{@model.table_name} where #{attr[:name]} like '#{query}%'")
      records.map{|r| [r.send(attr[:name]), r.send(attr[:name])]}
    end

    def foreign_key_for assoc_name
      @model.reflect_on_association(assoc_name.to_sym).foreign_key
    end

    # Returns the model class for association columns
    def class_for assoc_name
      @model.reflect_on_association(assoc_name.to_sym).klass
    end

    def destroy(ids)
      @model.destroy(ids)
    end

    # Returns a record by id.
    # Respects the following options:
    # * scope - will only return a record if it falls into the provided scope
    def find_record(id, options = {})
      # scope = options[:scope] || {}
      relation = @model.where(primary_key => id)
      relation = options[:scope].call(relation) if options[:scope].is_a?(Proc)
      relation.first
    end

    # Build a hash of foreign keys and the associated model
    def hash_fk_model
      foreign_keys = {}
      @model.reflect_on_all_associations(:belongs_to).map{ |r|
        foreign_keys[r.association_foreign_key.to_sym] = r.name
      }
      foreign_keys
    end

    # FIXME
    def move_records(params)
      if defined?(ActsAsList) && @model.ancestors.include?(ActsAsList::InstanceMethods)
        ids = JSON.parse(params[:ids]).reverse
        ids.each_with_index do |id, i|
          r = @model.find(id)
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
      @model.human_attribute_name(name)
    end

    def record_value_for_attribute(r, a, through_association = false)
      v = if association_attr?(a)
        split = a[:name].to_s.split(/\.|__/)
        assoc = @model.reflect_on_association(split.first.to_sym)
        if through_association
          split.inject(r) do |r, m| # Do we *really* need to descend deeper than 1 level?
            return nil if r.nil?

            # On the last iteration call the getter block
            if a[:getter] && split.last.equal?(m)
              a[:getter].call(r)
            elsif r.respond_to?(m)
              r.send(m)
            else
              logger.warn "Netzke: Wrong attribute name: #{a[:name]}" unless r.nil?
              nil
            end
          end
        else
          r.send("#{assoc.options[:foreign_key] || assoc.name.to_s.foreign_key}")
        end
      elsif a[:getter]
        a[:getter].call(r)
      elsif r.respond_to?("#{a[:name]}")
        r.send("#{a[:name]}")

      # the composite_primary_keys gem produces [Key1,Key2...] and [Value1,Value2...]
      # on primary_key and id requests. Basepack::AttrConfig converts the keys-array to an String.
      elsif primary_key.try(:to_s) == a[:name]
        r.id # return 'val1,val2...' on 'key1,key2...' composite_primary_keys
      end

      # a work-around for to_json not taking the current timezone into account when serializing ActiveSupport::TimeWithZone
      v = v.to_datetime.to_s(:db) if [ActiveSupport::TimeWithZone].include?(v.class)

      v
    end

    def set_record_value_for_attribute(record, attr, value)
      value = value.to_time_in_current_zone if value.is_a?(Date) # convert Date to Time
      unless attr[:read_only]
        if attr[:setter]
          attr[:setter].call(record, value)
        elsif record.respond_to?("#{attr[:name]}=")
          record.send("#{attr[:name]}=", value)
        elsif association_attr?(attr)
          split = attr[:name].to_s.split(/\.|__/)
          if attr[:nested_attribute]
            # We want:
            #     set_value_for_attribute({:name => :assoc_1__assoc_2__method, :nested_attribute => true}, 100)
            # =>
            #     record.assoc_1.assoc_2.method = 100
            split.inject(record) { |r,m| m == split.last ? (r && r.send("#{m}=", value) && r.save) : r.send(m) }
          else
            if split.size == 2
              # search for association and assign it to r
              assoc = @model.reflect_on_association(split.first.to_sym)
              assoc_method = split.last
              if assoc
                if assoc.macro == :has_one
                  assoc_instance = record.send(assoc.name)
                  if assoc_instance
                    assoc_instance.send("#{assoc_method}=", value)
                    assoc_instance.save # what should we do when this fails?..
                  else
                    # what should we do in this case?
                  end
                else

                  # set the foreign key to the passed value
                  # not that if a negative value is passed, we reset the association (set it to nil)
                  record.send("#{assoc.foreign_key}=", value.to_i < 0 ? nil : value)
                end
              else
                logger.warn "Netzke: Association #{assoc} is not known for class #{@model}"
              end
            else
              logger.warn "Netzke: Wrong attribute name: #{attr[:name]}"
            end
          end
        end
      end
    end

    # If association attribute is given, returns [method, association]
    # Else returns [attr_name]
    def method_and_assoc(attr_name)
      assoc_name, method = attr_name.to_s.split('__')
      assoc = @model.reflect_on_association(assoc_name.to_sym) if method
      assoc.nil? ? [attr_name] : [method, assoc]
    end

    # An ActiveRecord::Relation instance encapsulating all the necessary conditions.
    def get_relation(params = {})
      relation = @model.all

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
          relation = q[:proc].call(relation, q[:value], q[:operator]) if q[:proc]
        end

        and_query.delete_if{|q| q[:proc] }

        # apply other, non-Proc filters
        relation = relation.where(predicates_for_and_conditions(and_query))
      end

      if params[:scope].is_a?(Proc)
        relation = params[:scope].call(relation)
      else
        raise ArgumentError, "Expected scope to be a Proc, got #{params[:scope].class}" unless params[:scope].nil?
      end

      @relation = relation
    end

    def predicates_for_and_conditions(conditions)
      return nil if conditions.empty?

      predicates = conditions.map do |q|
        q = HashWithIndifferentAccess.new(q)

        attr = q[:attr]
        method, assoc = method_and_assoc(attr)

        arel_table = assoc ? Arel::Table.new(assoc.klass.table_name.to_sym) : @model.arel_table

        value = q["value"]
        op = q["operator"]

        attr_type = attr_type(attr)

        case attr_type
        when :datetime
          update_predecate_for_datetime(arel_table[method], op, value.to_date)
        when :string, :text
          update_predecate_for_string(arel_table[method], op, value)
        when :boolean
          update_predecate_for_boolean(arel_table[method], op, value)
        when :date
          update_predecate_for_rest(arel_table[method], op, value.to_date)
        else
          update_predecate_for_rest(arel_table[method], op, value)
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

    protected

    # Addresses the n+1 query problem
    # Returns updated relation
    def fix_nplus1_problem(relation, columns)
      columns.reduce(relation) do |rel, c|
        assoc, method = c[:name].split('__')
        method ? rel.includes(assoc.to_sym).references(assoc.to_sym) : rel
      end
    end

    def apply_sorting(relation, columns, sorters)
      return relation if sorters.blank?

      sorters = Array.new(sorters)

      relation = relation.reorder("") # reset eventual default_scope ordering

      sorters.reduce(relation) do |rel, sorter|
        sorter["direction"] ||= 'ASC'
        dir = sorter["direction"].downcase
        column = columns.detect { |c| c[:name] == sorter["property"] }
        column ||= {name: sorter["property"]} # stub column, as we may want to sort by a column that's not in the grid
        apply_column_sorting(rel, column, dir)
      end
    end

    def apply_column_sorting(relation, column, dir)
      assoc, method = column[:name].split('__')

      # if a sorting scope is set, call the scope with the given direction
      if column[:sorting_scope].is_a?(Proc)
        column[:sorting_scope].call(relation, dir.to_sym)
      else
        if method.nil?
          relation.order("#{@model.table_name}.#{assoc} #{dir}")
        else
          assoc = @model.reflect_on_association(assoc.to_sym)
          relation.includes(assoc.name).references(assoc.klass.table_name.to_sym).order("#{assoc.klass.table_name}.#{method} #{dir}")
        end
      end
    end

    def apply_offset(relation, params)
      return relation if params[:limit].blank?
      relation.offset(params[:start]).limit(params[:limit])
    end

    private

    def logger
      Netzke::Base.logger
    end
  end
end
