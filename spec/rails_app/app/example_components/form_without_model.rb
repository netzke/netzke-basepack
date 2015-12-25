class FormWithoutModel < Netzke::Form::Base
  def configure(c)
    c.items = [
      :text_field,
      {:name => :number_field, :type => :integer},
      {:name => :boolean_field, :type => :boolean, :input_value => true},
      {:name => :date_field, :type => :date},
      # {:name => :datetime_field, :type => :datetime}, #incompatible: no xtype
      {:name => :combobox_field, :xtype => :combo, :store => [[1, "One"], [2, "Two"], [3, "Three"]]},
      {:name => :time_field, :type => :time },
    ]

    super
  end

  endpoint :submit do |params|
    data = ActiveSupport::JSON.decode(params[:data])
    this.netzke_notify data.each_pair.map{ |k,v| "#{k.humanize}: #{v}" }.join("<br/>")
  end
end
