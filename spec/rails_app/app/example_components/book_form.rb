class BookForm < Netzke::Basepack::Form
  include Extras::BookPresentation

  attribute :author__last_name do |c|
    c.xtype = :displayfield
  end

  attribute :rating do |c|
    c.xtype = :combo
    c.store = [[1, "Good"], [2, "Average"], [3, "Poor"]]
  end

  attribute :author__updated_at do |c|
    c.read_only = true
  end

  attribute :author__first_name do |c|
    c.setter = author_first_name_setter
    c.scope = lambda {|r| r.limit(10)}
  end

  attribute :in_abundance do |c|
    c.xtype = :displayfield
    c.getter = in_abundance_getter
  end

  attribute :last_read_at do |c|
    c.excluded = true
  end

  def configure(c)
    c.record = Book.first

    super

    c.model = "Book"
    c.items = [
      :title,
      :author__first_name,
      :author__name,
      :author__last_name,
      :rating,
      :author__updated_at,
      :digitized,
      :exemplars,
      :in_abundance,
      {name: :updated_at},
      :last_read_at, # excluded
      :published_on

      # WIP: commalistcbg is kind of broken, giving an Ext error
      # {:name => :tags, :xtype => :commalistcbg, :options => %w(read cool recommend buy)},
      # WIP: waithing on nradiogroup
      # {:name => :rating, :xtype => :nradiogroup, :options => [[1, "Good"], [2, "Average"], [3, "Poor"]]}
    ]
  end
end
