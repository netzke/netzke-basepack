class FormWithoutModel < Netzke::Basepack::FormPanel
  def configuration
    super.merge(
      # :file_upload => true, # incompatible
      :items => [
        :text_field,
        {:name => :number_field, :attr_type => :integer},
        {:name => :boolean_field, :attr_type => :boolean, :input_value => true},
        {:name => :date_field, :attr_type => :date},
        # {:name => :datetime_field, :attr_type => :datetime}, #incompatible: no xtype
        {:name => :combobox_field, :xtype => :combo, :store => [[1, "One"], [2, "Two"], [3, "Three"]]},
        {:name => :time_field, :attr_type => :time },
      ]
     )
  end

  def netzke_submit_endpoint(params)
    data = ActiveSupport::JSON.decode(params[:data])
    {:netzke_feedback => data.each_pair.map{ |k,v| "#{k.humanize}: #{v}" }.join("<br/>")}
  end
end
