class BookGrid < Netzke::Basepack::GridPanel
  js_property :title, I18n.t('books', :default => "Books")

  def default_config
    super.merge(
      :model => "Book",
      # :columns => [{:name => :author__first_name, :read_only => true}, :exemplars, {:name => :digitized, :xtype => :checkcolumn, :editable => false}]
      # :columns => [{:name => :title, :editable => false, :editor => {:xtype => :datefield}}, :exemplars, :digitized, :notes]
    )
  end
end
