# Warning: this component participates in i18n.feature, careful with adding new fields!
class BookForm < Netzke::Basepack::FormPanel
  js_property :title, Book.model_name.human

  include BookPresentation

  def configuration
    super.merge(
      :model => "Book",
      :record => Book.first,
      :items => [
        :title,
        {:name => :author__first_name, :setter => author_first_name_setter},
        {:name => :author__last_name, :xtype => :displayfield},
        {:name => :author__updated_at, :editable => false},
        :digitized,
        :exemplars,
        {:name => :in_abundance, :getter => in_abundance_getter, :xtype => :displayfield},
        {:name => :tags, :xtype => :commalistcbg, :options => %w(read cool recommend buy)},
        # WIP: waithing on nradiogroup
        # {:name => :rating, :xtype => :nradiogroup, :options => [[1, "Good"], [2, "Average"], [3, "Poor"]]}
      ]
    )
  end

  js_method :init_component, <<-JS
    function(){
      this.callParent( arguments );
      this.on('submitsuccess', function(){ this.feedback('Suc'+'cess!')}, this);
    }
  JS


end
