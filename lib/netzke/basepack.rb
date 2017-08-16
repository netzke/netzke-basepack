module Netzke
  module Basepack
    autoload :ActionColumn, 'netzke/basepack/action_column'
    autoload :ActiveRecord, 'netzke/basepack/active_record'
    autoload :AttrConfig, 'netzke/basepack/attr_config'
    autoload :Attributes, 'netzke/basepack/attributes'
    autoload :ColumnConfig, 'netzke/basepack/column_config'
    autoload :Columns, 'netzke/basepack/columns'
    autoload :DataAccessor, 'netzke/basepack/data_accessor'
    autoload :DataAdapters, 'netzke/basepack/data_adapters'
    autoload :DynamicTabPanel, 'netzke/basepack/dynamic_tab_panel'
    autoload :FieldConfig, 'netzke/basepack/field_config'
    autoload :Fields, 'netzke/basepack/fields'
    autoload :GridLiveSearch, 'netzke/basepack/grid_live_search'
    autoload :ItemPersistence, 'netzke/basepack/item_persistence'
    autoload :PagingForm, 'netzke/basepack/paging_form'
    autoload :QueryBuilder, 'netzke/basepack/query_builder'
    autoload :RecordFormWindow, 'netzke/basepack/record_form_window'
    autoload :SearchPanel, 'netzke/basepack/search_panel'
    autoload :SearchWindow, 'netzke/basepack/search_window'
    autoload :VERSION, 'netzke/basepack/version'

    if defined? ActiveRecord
      require 'netzke/basepack/data_adapters/active_record_adapter'
    end

    mattr_accessor :with_icons

    mattr_accessor :icons_uri

    class << self
      # Called from netzke-basepack.rb
      def init
        %w[bugfixes tristate netzkeremotecombo xdatetime basepack grid/columns grid/event_handlers].each do |name|
          Netzke::Core.ext_javascripts << "#{File.dirname(__FILE__)}/../../javascripts/#{name}.js"
        end

        Netzke::Core.ext_stylesheets << "#{File.dirname(__FILE__)}/../../stylesheets/basepack.css"
      end

      # Use this to confirure Basepack in the initializers, e.g.:
      #
      #     Netzke::Basepack.setup do |config|
      #       config.icons_uri = "/images/famfamfam/icons"
      #     end
      def setup
        yield self
      end
    end
  end
end
