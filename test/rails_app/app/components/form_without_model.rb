class FormWithoutModel < Netzke::Basepack::FormPanel
  def configuration
    super.merge(
      :items => [
        :text_field,
        {:name => :number_field, :attr_type => :integer},
        {:name => :boolean_field, :attr_type => :boolean},
        {:name => :date_field, :attr_type => :date},
        {:name => :datetime_field, :attr_type => :datetime},
        {:name => :combobox_field, :xtype => :combo, :store => ["One", "Two", "Three"]}
      ]
    )
  end

  def netzke_submit_endpoint(params)
    data = ActiveSupport::JSON.decode(params.data)
    {:feedback => data.each_pair.map{ |k,v| "#{k.humanize}: #{v}" }.join("<br/>")}
  end
end
