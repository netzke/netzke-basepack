class Form::NoModel < Netzke::Form::Base
  def items
    [
      :text_field,
      {:name => :number_field, :type => :integer},
      {:name => :boolean_field, :type => :boolean, :input_value => true},
      {:name => :date_field, :type => :date},
      # {:name => :datetime_field, :type => :datetime}, #incompatible: no xtype
      {:name => :combobox_field, :xtype => :combo, :store => [[1, "One"], [2, "Two"], [3, "Three"]]},
      {:name => :time_field, :type => :time },
    ]
  end

  endpoint :submit do |params|
    data = ActiveSupport::JSON.decode(params[:data])
    client.netzke_feedback data.each_pair.map{ |k,v| "#{k.humanize}: #{v}" }.join("<br/>")
  end
end
