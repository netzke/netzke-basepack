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
    class PagingFormPanel < FormPanel

      # override
      def record
        get_relation.first
      end

      # Pass total records amount and the first record to the JS constructor
      def js_config
        super.merge({
          :total_records => total_records,
          :record => record.to_hash(fields)
        })
      end

      endpoint :get_data do |params|
        record = get_relation.offset(params[:start].to_i).limit(1).first
        {:records => record && [record.to_hash(fields)] || [], :total => total_records}
      end

      js_method :init_component, <<-JS
        function(){

          var fieldNames = [];
          for (var f in this.fields) {
            fieldNames.push(f);
          }

          var store = new Ext.data.JsonStore({
            url: this.endpointUrl('get_data'),
            root: 'records',
            fields: fieldNames,
            data: {records: [this.record], total: this.totalRecords}
          });

          store.on('beforeload', function(){
            if (!this.loadMaskCmp) this.loadMaskCmp = new Ext.LoadMask(this.bwrap, this.applyMask);
            this.loadMaskCmp.show();
          }, this);

          store.on('load', function(st, r){
            this.getForm().setValues(r[0].data);
            if (this.loadMaskCmp) this.loadMaskCmp.hide();
          }, this);

          this.bbar = new Ext.PagingToolbar({
            beforePageText: "Record",
            store: store,
            pageSize: 1,
            items: ["-"].concat(this.bbar || [])
          });

          Netzke.classes.Basepack.PagingFormPanel.superclass.initComponent.call(this);
        }
      JS

      protected

        # Returns ActiveRecord::Relation for the data
        def get_relation
          relation = data_class.scoped
          relation = relation.extend_with(config[:scope]) if config[:scope]
          relation
        end

        def total_records
          @total_records ||= get_relation.count
        end

    end
  end
end
