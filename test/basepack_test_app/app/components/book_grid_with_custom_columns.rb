class BookGridWithCustomColumns < Netzke::Basepack::GridPanel
  js_property :title, "Books"

  model "Book"

  column :author__first_name do |c|
    c.renderer = :my_renderer
  end

  column :author__list_name do |c|
    c.renderer = :uppercase
  end

  column :author_name do |c|
    c.flex = 1
    c.text = "Author"
  end

  column :title do |c|
    c.flex = 1
  end

  column :rating do |c|
    c.editor = {
      :trigger_action => :all,
      :xtype => :combo,
      :store => [[1, "Good"], [2, "Average"], [3, "Poor"]]
    }

    c.renderer = "function(v){return ['', 'Good', 'Average', 'Poor'][v];}"
  end

  def columns
    [ :author__first_name, :author__last_name, :author__name, :title, :digitized, :rating, :exemplars, :updated_at ]
  end

  #column :author__first_name, :renderer => :my_renderer
  #column :author__last_name, :renderer => :uppercase
  #column :author__name, :flex => 1, :text => "Author"
  #column :title, :flex => 1
  #column :digitized
  #column :rating,
    #:editor => {
      #:trigger_action => :all,
      #:xtype => :combo,
      #:store => [[1, "Good"], [2, "Average"], [3, "Poor"]]
    #},
    #:renderer => "function(v){return ['', 'Good', 'Average', 'Poor'][v];}"
  #column :exemplars
  #column :updated_at

  js_method :my_renderer, <<-JS
    function(value){
      return value ? "*" + value + "*" : "";
    }
  JS
end
