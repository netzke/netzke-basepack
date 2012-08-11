class BookPagingFormPanel < Netzke::Basepack::PagingFormPanel
  def configure(c)
    c.title = "Digitized books"
    c.model = "Book"
    c.record = Book.first
    # :scope => {:digitized => true},
    c.mode = :lockable
    c.items = [{:layout => :hbox, :label_align => :top, :border => false, :defaults => {:border => false}, :items => [{
      :flex => 2,
      :layout => :anchor,
      :defaults => {:anchor => "-8"},
      :items => [:title, :notes, :digitized, :created_at, :updated_at, :last_read_at]
    },{
      :flex => 1,
      :layout => :anchor,
      :defaults => {:anchor => "-8"},
      :items => [:author__name, {:name => :author__first_name, :read_only => true}, :exemplars, :published_on]
    }]}]
    super
  end
end
