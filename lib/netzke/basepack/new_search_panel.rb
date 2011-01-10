module Netzke
  module Basepack
    class NewSearchPanel < Base

      js_base_class "Ext.form.FormPanel"

      js_properties(
        :header => false,
        :padding => 5
      )

      js_include :init, :condition_field

      js_mixin :main

      # TODO: i18n
      js_property :attribute_operators_map, {
        :integer => [
          ["gt", "Greater than"],
          ["lt", "Less than"]
        ],
        :string => [
          ["contains", "Contains"], # same as matches => %string%
          ["matches", "Matches"]
        ],
        :boolean => [
          ["is_true", "Yes"],
          ["is_false", "No"]
        ],
        :datetime => [
          ["gt", "After"],
          ["lt", "Before"]
        ]
      }

      action :clear_all, :icon => :cross
      action :add_condition, :icon => :add
      action :serialize, :icon => :information

      def default_query
        data_class.column_names.map do |c|
          column_type = data_class.columns_hash[c].type
          operator = (self.class.js_property(:attribute_operators_map)[column_type] || []).first.try(:fetch, 0) || "matches"
          {:attr => c, :attr_type => column_type, :operator => operator}
        end
      end

      def configuration
        super.merge({
          :bbar => [:add_condition.action, :clear_all.action, "-", :serialize.action]
        })
      end

      def data_class
        @data_class ||= config[:model].constantize
      end

      def js_config
        super.merge(
          :attrs => data_class.column_names,
          :attrs_hash => data_class.column_names.inject({}){ |hsh,c| hsh.merge(c => data_class.columns_hash[c].type) },
          :query => config[:query] || default_query
        )
      end

      js_method :init_component, <<-JS
        function(){
          Netzke.classes.Basepack.NewSearchPanel.superclass.initComponent.call(this);

          Ext.each(this.query, function(f){
            this.add(Ext.apply(f, {xtype: 'netzkebasepacknewsearchpanelconditionfield'}));
          }, this);

          // this.add({
          //   xtype: 'compositefield',
          //   hideLabel: true,
          //   items: [{
          //     // work-around button display problem
          //     xtype: 'textfield',
          //     hidden: true
          //   },{
          //     xtype: 'button',
          //     // cls: 'x-btn-icon',
          //     text: 'Add condition',
          //     icon: "/images/icons/add.png",
          //     handler: this.onAddField,
          //     scope: this
          //   },{
          //     xtype: 'button',
          //     // cls: 'x-btn-icon',
          //     text: 'Clear all',
          //     icon: "/images/icons/cross.png",
          //     handler: this.onClearAll,
          //     scope: this
          //   }]
          //
          // });
        }
      JS

      js_method :on_add_condition, <<-JS
        function(){
          this.add({xtype: 'netzkebasepacknewsearchpanelconditionfield'});
          this.doLayout();
        }
      JS

      js_method :on_clear_all, <<-JS
        function(){
          this.removeAll();
        }
      JS

      js_method :on_serialize, <<-JS
        function(){
          console.info("this.getQuery(): ", this.getQuery());
        }
      JS

      js_method :get_query, <<-JS
        function(){
          var query = [];
          this.items.each(function(f){
            if (f.valueIsSet()) {
              query.push(f.buildValue());
            }
          });
          return query;
        }
      JS


    end
  end
end
