class Grid::CustomFormLayout < Netzke::Grid::Base
  attribute :exemplars do |c|
    c.read_only = true
  end

  attribute :notes do |c|
    c.label = "Remarks"
    c.field_config = {xtype: :displayfield}
  end

  def configure(c)
    super

    c.model = "Book"

    c.columns = [:title, :notes]

    c.form_items = [
      :author__name,
      {
        xtype: 'fieldset', title: "Basic Info", items: [
          :title,
          :exemplars
        ]
      },
      {
        xtype: 'fieldset', title: "Timestamps", items: [
          {name: :created_at, disabled: true},
          {name: :updated_at, disabled: true}
        ]
      },
      :notes
    ]
  end
end
