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
        {:name => :rating, :xtype => :combo, :store => [[1, "Good"], [2, "Average"], [3, "Poor"]]},
        {:name => :author__updated_at, :editable => false},
        :digitized,
        :exemplars,
        {:name => :in_abundance, :getter => in_abundance_getter, :xtype => :displayfield},
        # WIP: commalistcbg is kind of broken, giving an Ext error
        # {:name => :tags, :xtype => :commalistcbg, :options => %w(read cool recommend buy)},
        # WIP: waithing on nradiogroup
        # {:name => :rating, :xtype => :nradiogroup, :options => [[1, "Good"], [2, "Average"], [3, "Poor"]]}
      ]
    )
  end

  js_method :init_component, <<-JS
    function(){
      this.callParent();
      this.on('submitsuccess', function(){ this.feedback('Suc'+'cess!')}, this);
    }
  JS


end
