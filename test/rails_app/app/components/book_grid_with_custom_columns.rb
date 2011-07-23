class BookGridWithCustomColumns < Netzke::Basepack::GridPanel
  js_property :title, "Books"

  def default_config
    super.merge(
      :model => "Book",
      :columns => [
        {:name => :author__first_name, :renderer => :my_renderer},
        {:name => :author__last_name, :renderer => :uppercase},
        {:name => :author__name, :flex => 1},
        {:name => :title, :flex => 1},
        {:name => :digitized},
        {
          :name => :rating,
          :editor => {
            :trigger_action => :all,
            :xtype => :combo,
            :store => [[1, "Good"], [2, "Average"], [3, "Poor"]]
          },
          :renderer => "function(v){return ['', 'Good', 'Average', 'Poor'][v];}"
        },
        :exemplars,
        {:name => :updated_at}
      ]
    )
  end

  js_method :my_renderer, <<-JS
    function(value){
      return value ? "*" + value + "*" : "";
    }
  JS

end
