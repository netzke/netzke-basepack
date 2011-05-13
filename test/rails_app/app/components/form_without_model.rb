class FormWithoutModel < Netzke::Basepack::FormPanel
  def configuration
    super.merge(
      # :file_upload => true, # incompatible
      # :items => [
      #   :text_field,
      #   {:name => :number_field, :attr_type => :integer},
      #   # {:name => :boolean_field, :attr_type => :boolean, :input_value => true}, #incompatible
      #   {:name => :date_field, :attr_type => :date},
      #   {:name => :datetime_field, :attr_type => :datetime}, #incompatible: no xtype
      #   {:name => :combobox_field, :xtype => :combo, :store => [[1, "One"], [2, "Two"], [3, "Three"]]},
      #   {:name => :time_field, :attr_type => :time },
      # ]
      #

      items:[
       {
        xtype: 'container',
        layout: 'hbox',
        margin: '0 0 10',
        items: [{
            xtype: 'fieldset',
            flex: 1,
            title: 'Individual Checkboxes',
            default_type: 'checkbox',
            layout: 'anchor',
            defaults: {
                anchor: '100%',
                hide_empty_label: false
            },
            items: [{
                xtype: 'textfield',
                name: 'txt-test1',
                field_label: 'Alignment Test'
            }, {
                field_label: 'Favorite Animals',
                box_label: 'Dog',
                name: 'fav-animal-dog',
                input_value: 'dog',
                # xtype: 'checkbox',
                checked: false
            }, {
                box_label: 'Cat',
                name: 'fav-animal-cat',
                input_value: 'cat',
                # xtype: 'checkbox',
                checked: false
            }, {
                checked: true,
                box_label: 'Monkey',
                name: 'fav-animal-monkey',
                input_value: 'monkey',
                xtype: 'checkbox'
            }]
        }, {
            xtype: 'component',
            width: 10
        }, {
            xtype: 'fieldset',
            flex: 1,
            title: 'Individual Radios',
            defaultType: 'radio', 
            layout: 'anchor',
            defaults: {
                anchor: '100%',
                hideEmptyLabel: false
            },
            items: [{
                xtype: 'textfield',
                name: 'txt-test2',
                fieldLabel: 'Alignment Test'
            }, {
                checked: true,
                fieldLabel: 'Favorite Color',
                boxLabel: 'Red',
                name: 'fav-color',
                inputValue: 'red'
            }, {
                boxLabel: 'Blue',
                name: 'fav-color',
                inputValue: 'blue'
            }, {
                boxLabel: 'Green',
                name: 'fav-color',
                inputValue: 'green'
            }]
        }]
      }]
    )
  end

  def netzke_submit_endpoint(params)
    data = ActiveSupport::JSON.decode(params[:data])
    {:feedback => data.each_pair.map{ |k,v| "#{k.humanize}: #{v}" }.join("<br/>")}
  end
end
