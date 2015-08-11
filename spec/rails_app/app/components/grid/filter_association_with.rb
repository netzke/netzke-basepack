class Grid::FilterAssociationWith < Netzke::Basepack::Grid
  model 'Book'

  def columns
    [
        { name: :author__custom_name, text: 'Author', getter: ->(r){ "#{r.first_name} #{r.last_name}" }, filter_association_with: ->(r, v){ r.where('year > ?', v)} },
        { name: :title, text: 'title'},
    ]
  end
end
