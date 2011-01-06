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

      # Todo: i18n
      js_property :attribute_operators_map, {
        :integer => [
          ["gt", "Greater than"],
          ["lt", "Less than"]
        ],
        :string => [
          ["matches", "Contains"]
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

      # def default_config
      #   super.merge(
      #     :query => [
      #       {:attr => "title", :attr_type => :string, :operator => "contains", :value => "Lol"},
      #       {:attr => "digitized", :attr_type => :boolean, :operator => "is_true"},
      #       {:attr => "exemplars", :attr_type => :integer, :operator => "lt", :value => 100}
      #     ]
      #   )
      # end

      def configuration
        super.merge({
          :bbar => [:add_condition.action, :clear_all.action, "-", :serialize.action]
        })
      end

      def data_class
        config[:model].constantize
      end

      def js_config
        super.merge(
          :attrs => data_class.column_names,
          :attrs_hash => data_class.column_names.inject({}){ |hsh,c| hsh.merge(c => data_class.columns_hash[c].type) },
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
            var fieldValues = {};
            f.items.each(function(i){
              if (i.value) fieldValues[i.name] = i.value;
            });
            if (fieldValues.attr && fieldValues.operator) query.push(fieldValues);
          });
          return Ext.encode(query);
        }
      JS


    end
  end
end
