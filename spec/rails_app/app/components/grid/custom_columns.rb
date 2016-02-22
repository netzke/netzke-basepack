class Grid::CustomColumns < Netzke::Grid::Base
  attribute :author__first_name do |c|
    c.column_config = {renderer: :my_renderer}
    c.field_config = {excluded: true}
  end

  attribute :author__last_name do |c|
    c.column_config = {renderer: :uppercase}
    c.read_only = true
  end

  attribute :author__name do |c|
    c.column_config = {
      sorting_scope: lambda do |relation, dir|
        relation.joins(:author).order("authors.first_name #{dir}, authors.last_name #{dir}")
      end,
      flex: 1
    }

    c.label = "Author"
  end

  attribute :title do |c|
    c.column_config = {flex: 1}
  end

  attribute :rating do |c|
    editor = {
      :trigger_action => :all,
      :xtype => :combo,
      :store => [[1, "Good"], [2, "Average"], [3, "Poor"]]
    }

    c.column_config = {
      renderer: "function(v){return ['', 'Good', 'Average', 'Poor'][v];}",
      editor: editor
    }

    c.field_config = editor
  end

  attribute :extra_column do |c|
    c.label = 'Extra stuff'
  end

  def configure(c)
    c.model = "Book"

    c.attributes = [
      :author__first_name, :author__last_name, :author__name, :title, :digitized, :rating, :exemplars, :updated_at
    ]
    super
  end

  # This way we'll always have the extra_column, independent of the columns provided in the configuration
  def attributes
    super + [:extra_column]
  end

  client_class do |c|
    c.my_renderer = l(<<-JS)
      function(value){
        return value ? "*" + value + "*" : "";
      }
    JS
  end
end
