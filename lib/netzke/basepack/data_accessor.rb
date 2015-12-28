module Netzke
  module Basepack
    # This module is included into such data-driven components as Grid, Form, PagingForm, etc.
    module DataAccessor
      # Model class as specified in configuration. May be handy to override.
      # Returns ORM model class.
      def model
        @model ||= config[:model].is_a?(String) ? config[:model].constantize : config[:model]
      end

      # Data adapter responsible for all DB-related operations.
      # Note that if model is nil, AbstractAdapter will used.
      def model_adapter
        @model_adapter ||= Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(model).new(model)
      end
    end
  end
end
