module Netzke
  module Basepack
    # A FormPanel with paging toolbar. Allows browsing and editing records one-by-one.
    #
    # == Configuration
    # Besides +Netzke::Basepack::FormPanel+ config options, accepts:
    # * +scope+ - specifies how the data should be filtered.
    #   When it's a symbol, it's used as a scope name.
    #   When it's a string, it's a SQL statement (passed directly to +ActiveRecord::Relation#where+).
    #   When it's a hash, it's a conditions hash (passed directly to +ActiveRecord::Relation#where+).
    #   When it's an array, it's expanded into an SQL statement with arguments (passed directly to +ActiveRecord::Relation#where+), e.g.:
    #
    #     :scope => ["id > ?", 100])
    #
    #   When it's a Proc, it's passed the model class, and is expected to return an ActiveRecord::Relation, e.g.:
    #
    #     :scope => { |rel| rel.where(:id.gt => 100).order(:created_at) }
    #
    # == ToDo
    # * Update the number of records after form submit
    class PagingFormPanel < FormPanel
      js_mixin :paging_form_panel

      # override
      def record
        @record ||= data_adapter.first
      end

      # Pass total records amount and the first record to the JS constructor
      def js_config
        super.merge({
          :total_records => total_records
        })
      end

      endpoint :get_data do |params|
        @record = data_adapter.get_records(params).first
        record_hash = @record && js_record_data
        {:records => record_hash && [record_hash] || [], :total => total_records(params)}
      end

      action :search do
        {
          :text => I18n.t('netzke.basepack.paging_form_panel.actions.search'),
          :tooltip => I18n.t('netzke.basepack.paging_form_panel.actions.search_tooltip'),
          :icon => :find,
          :select => true
        }
      end

      def configure_bbar(c)
        super
        c[:bbar] << :search.action
      end

      component :search_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::SearchWindow",
          :model => config[:model]
        }
      end

      protected

        def total_records(params = {})
          @total_records ||= data_adapter.count_records(params, {})
        end

    end
  end
end
