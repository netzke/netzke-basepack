module Netzke
  module Basepack
    # This module is included into such data-driven components as Grid, Form, PagingForm, etc.
    module DataAccessor
      # Model class
      def model_class
        @model_class ||= config[:model].is_a?(String) ? config[:model].constantize : config[:model]
      end

      # Data adapter responsible for all DB-related operations.
      # Note that if model_class is nil, AbstractAdapter will used.
      def model_adapter
        @model_adapter ||= Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(model_class).new(model_class)
      end

      def hashify_attribute(a)
        a.is_a?(Symbol) || a.is_a?(String) ? {name: a.to_s} : a
      end
    end
  end
end
