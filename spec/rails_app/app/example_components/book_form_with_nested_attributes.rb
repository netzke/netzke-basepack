# TODO: not used atm
class BookFormWithNestedAttributes < Netzke::Form::Base
  def configure(c)
    c.merge!(
      :title => Book.model_name.human,
      :model => "Book",
      :record => Book.first,
      :items => [
        :title,
        {:name => :author__first_name, :nested_attribute => true},
        {:name => :author__last_name, :nested_attribute => true},
        :digitized,
        :exemplars
      ]
    )
  end
end
