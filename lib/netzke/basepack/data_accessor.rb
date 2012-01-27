module Netzke
  module Basepack
    # This module is included into such data-driven components as GridPanel, FormPanel, PagingFormPanel, etc.
    module DataAccessor



      # Returns options for comboboxes in grids/forms
      def combobox_options_for_column(column, method_options = {})
        data_adapter.combobox_options_for_column column, method_options
      end

      # Normalize array of attributes
      # [:col1, "col2", {:name => :col3}] =>
      #   [{:name => "col1"}, {:name => "col2"}, {:name => "col3"}]
      def normalize_attrs(attrs)
        attrs.map{ |a| normalize_attr(a) }
      end

      # Normalize an attribute, e.g.:
      # :first_name =>
      #   {:name => "first_name"}
      def normalize_attr(a)
        a.is_a?(Symbol) || a.is_a?(String) ? {:name => a.to_s} : a.merge(:name => a[:name].to_s)
      end

      def association_attr?(name)
        !!name.to_s.index("__")
      end

      # Model class
      def data_class
        @data_class ||= config[:model].is_a?(String) ? config[:model].constantize : config[:model]
      end

      # Data adapter responsible for all DB-related operations
      def data_adapter
        @data_adapter ||= Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(data_class).new(data_class)
      end

      # whether a column is bound to the primary_key
      def primary_key_attr?(a)
        data_class && a[:name].to_s == data_class.primary_key
      end

      # Mark an attribute as "virtual" by default, when it doesn't reflect a model column, or a model column of an association
      def set_default_virtual(c)
        c[:virtual] = data_adapter.column_virtual?(c) if c[:virtual].nil?
      end

    end
  end
end
