class BookFormWithCustomFields < Netzke::Basepack::FormPanel
  js_property :title, Book.model_name.human

  def default_config
    super.merge(
      :model => "Book",
      :record => Book.first,
      # :mode => :lockable,
      :items => [
        :title,
        {:name => :notes, :read_only => true},
        :author__first_name,
        :author__last_name,
        :digitized,
        :exemplars
      ]
    )
  end

end
