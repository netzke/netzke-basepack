class BookGridWithCustomColumns < Netzke::Basepack::GridPanel
  js_property :title, "Books"

  def default_config
    super.merge(
      :model => "Book",
      :columns => [
        :author__first_name,
        :author__last_name,
        :author__name,
        :title,
        {
          :name => :rating,
          :editor => {
            :trigger_action => :all,
            :xtype => :combo,
            :store => [[1, "Good"], [2, "Average"], [3, "Poor"]]
          },
          :renderer => "function(v){return ['', 'Good', 'Average', 'Poor'][v];}"
        }
      ]
    )
  end

end
