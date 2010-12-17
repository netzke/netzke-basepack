class BookForm < Netzke::Basepack::FormPanel
  js_property :title, Book.model_name.human

  include BookPresentation

  def default_config
    super.merge(
      :model => "Book",
      :record => Book.first,
      :items => [
        :title,
        {:name => :author__first_name, :setter => author_first_name_setter},
        :digitized,
        :exemplars,
        {:name => :in_abundance, :getter => in_abundance_getter, :xtype => :displayfield},
        {:name => :tags, :xtype => :commalistcbg, :options => %w(read cool recommend buy)},
        {:name => :rating, :xtype => :nradiogroup, :options => %w(Good Average Poor)}
      ]
    )
  end

end
